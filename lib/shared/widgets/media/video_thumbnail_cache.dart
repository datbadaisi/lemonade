import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:path_provider/path_provider.dart';

/// RAM + disk cache of first-frame stills for native video URLs.
///
/// Feed cards and post detail share this so opening a post does not re-download
/// / re-decode a video just to show the same poster frame again.
///
/// **Concurrency**: mid-range Android (e.g. MT6835 software AV1) dies under
/// stampede — profile showed ~180 allocate/start/stop cycles when every
/// on-screen [VideoThumbnailPlayer] called the plugin at once. Cap to one
/// active extract; queue the rest.
///
/// **Disk**: JPEG stills under app cache (`video_thumbs/`). Survives process
/// death so repeat visits do not pay MediaCodec again.
class VideoThumbnailCache {
  VideoThumbnailCache._();

  /// One MediaCodec pipeline at a time — two concurrent still hitch on A-series.
  static const int maxConcurrent = 1;

  /// Codec start is slower than still decode; still hard-bounded.
  static const Duration _extractTimeout = Duration(seconds: 15);

  static const int _maxRamEntries = 24;

  /// Cap disk footprint (~few MB of small JPEGs).
  static const int _maxDiskEntries = 80;

  /// List cells: smaller stills decode faster and look fine at card width.
  static const int defaultMaxWidth = 360;
  static const int defaultQuality = 50;

  static final Map<String, Uint8List> _bytes = {};
  /// Shared future per URL so duplicate requests coalesce.
  static final Map<String, Future<Uint8List?>> _futures = {};
  static int _inFlight = 0;
  static final Queue<_ThumbJob> _queue = Queue<_ThumbJob>();

  static Directory? _diskDir;
  static Future<Directory?>? _diskDirFuture;

  /// Synchronous hit used to paint without a loading spinner.
  static Uint8List? peek(String videoUrl) => _bytes[videoUrl];

  static int get pendingCount => _inFlight + _queue.length;

  static Future<Uint8List?> load(
    String videoUrl, {
    int maxWidth = defaultMaxWidth,
    int quality = defaultQuality,
  }) {
    if (videoUrl.isEmpty) return Future<Uint8List?>.value(null);

    final hit = _bytes[videoUrl];
    if (hit != null) return Future<Uint8List?>.value(hit);

    return _futures.putIfAbsent(videoUrl, () async {
      try {
        // Disk before codec queue — cheap, and does not block MediaCodec slot.
        final fromDisk = await _readDisk(videoUrl);
        if (fromDisk != null) return fromDisk;

        return await _enqueueExtract(
          videoUrl,
          maxWidth: maxWidth,
          quality: quality,
        );
      } finally {
        _futures.remove(videoUrl);
      }
    });
  }

  static Future<Uint8List?> _enqueueExtract(
    String videoUrl, {
    required int maxWidth,
    required int quality,
  }) {
    final job = _ThumbJob(
      url: videoUrl,
      maxWidth: maxWidth,
      quality: quality,
    );
    if (_inFlight < maxConcurrent) {
      _run(job);
    } else {
      _queue.add(job);
    }
    return job.completer.future;
  }

  static void _run(_ThumbJob job) {
    _inFlight++;
    () async {
      try {
        final existing = _bytes[job.url];
        if (existing != null) {
          if (!job.completer.isCompleted) {
            job.completer.complete(existing);
          }
          return;
        }

        final fromDisk = await _readDisk(job.url);
        if (fromDisk != null) {
          if (!job.completer.isCompleted) {
            job.completer.complete(fromDisk);
          }
          return;
        }

        // Bound MediaCodec / network extract so one bad video cannot pin
        // the single thumbnail slot forever (same class of bug as image budget).
        final data = await FlutterVideoThumbnailPlus.thumbnailData(
          video: job.url,
          imageFormat: ImageFormat.jpeg,
          maxWidth: job.maxWidth,
          quality: job.quality,
        ).timeout(_extractTimeout, onTimeout: () => null);
        if (data != null && data.isNotEmpty) {
          _remember(job.url, data);
          // Fire-and-forget; RAM already holds the still for paint.
          unawaited(_writeDisk(job.url, data));
        }
        if (!job.completer.isCompleted) {
          job.completer.complete(data);
        }
      } catch (_) {
        if (!job.completer.isCompleted) {
          job.completer.complete(null);
        }
      } finally {
        _inFlight--;
        _pump();
      }
    }();
  }

  static void _pump() {
    while (_inFlight < maxConcurrent && _queue.isNotEmpty) {
      _run(_queue.removeFirst());
    }
  }

  /// Drop queued (not started) jobs — e.g. before jump-to-top so deep-scroll
  /// thumbnail work does not fight top-card mounts.
  static void clearPending() {
    while (_queue.isNotEmpty) {
      final job = _queue.removeFirst();
      if (!job.completer.isCompleted) {
        job.completer.complete(null);
      }
    }
  }

  static void _remember(String url, Uint8List data) {
    if (_bytes.length >= _maxRamEntries && !_bytes.containsKey(url)) {
      _bytes.remove(_bytes.keys.first);
    }
    _bytes[url] = data;
  }

  /// Clears **RAM** only. Disk stills stay so the next session is cheap.
  static void clear() {
    _bytes.clear();
    clearPending();
  }

  /// Test helper — wipe disk cache too.
  static Future<void> clearDisk() async {
    try {
      final dir = await _ensureDiskDir();
      if (dir == null) return;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      _diskDir = null;
      _diskDirFuture = null;
    } catch (_) {}
  }

  // ── Disk ──────────────────────────────────────────────────────────────────

  static Future<Directory?> _ensureDiskDir() {
    if (_diskDir != null) return Future<Directory?>.value(_diskDir);
    return _diskDirFuture ??= () async {
      try {
        final root = await getApplicationCacheDirectory();
        final dir = Directory('${root.path}${Platform.pathSeparator}video_thumbs');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        _diskDir = dir;
        return dir;
      } catch (_) {
        _diskDirFuture = null;
        return null;
      }
    }();
  }

  /// Stable, filesystem-safe key from URL (FNV-1a 64-bit hex).
  static String _fileKey(String url) {
    final bytes = utf8.encode(url);
    var hash = 0xcbf29ce484222325;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static File _fileFor(Directory dir, String url) {
    return File(
      '${dir.path}${Platform.pathSeparator}${_fileKey(url)}.jpg',
    );
  }

  static Future<Uint8List?> _readDisk(String url) async {
    try {
      final dir = await _ensureDiskDir();
      if (dir == null) return null;
      final file = _fileFor(dir, url);
      if (!await file.exists()) return null;
      final data = await file.readAsBytes();
      if (data.isEmpty) return null;
      _remember(url, data);
      // Touch mtime so LRU eviction keeps recently used stills.
      try {
        await file.setLastModified(DateTime.now());
      } catch (_) {}
      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeDisk(String url, Uint8List data) async {
    try {
      final dir = await _ensureDiskDir();
      if (dir == null) return;
      final file = _fileFor(dir, url);
      await file.writeAsBytes(data, flush: false);
      await _evictDiskIfNeeded(dir);
    } catch (_) {}
  }

  static Future<void> _evictDiskIfNeeded(Directory dir) async {
    try {
      final files = await dir
          .list()
          .where((e) => e is File && e.path.endsWith('.jpg'))
          .cast<File>()
          .toList();
      if (files.length <= _maxDiskEntries) return;

      final stamped = <({File file, DateTime mtime})>[];
      for (final f in files) {
        try {
          stamped.add((file: f, mtime: await f.lastModified()));
        } catch (_) {
          stamped.add((file: f, mtime: DateTime.fromMillisecondsSinceEpoch(0)));
        }
      }
      stamped.sort((a, b) => a.mtime.compareTo(b.mtime));
      final toRemove = stamped.length - _maxDiskEntries;
      for (var i = 0; i < toRemove; i++) {
        try {
          await stamped[i].file.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}

final class _ThumbJob {
  _ThumbJob({
    required this.url,
    required this.maxWidth,
    required this.quality,
  });

  final String url;
  final int maxWidth;
  final int quality;
  final Completer<Uint8List?> completer = Completer<Uint8List?>();
}
