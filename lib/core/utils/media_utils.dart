import 'package:bluerum/shared/models/post.dart';

enum MediaType { image, video }

enum VideoType { native, youtube }

/// Unwrap nested Lemmy `image_proxy` URLs for extension/type detection only.
/// Do **not** use the result as the load URL — keep the proxy for fetching.
String cleanImageProxyUrl(String url) {
  String currentUrl = url;
  final seen = <String>{};
  // A federated post controls this value. Bound nested proxy parsing so a
  // pathological URL cannot keep the UI isolate busy indefinitely.
  while (currentUrl.contains('image_proxy') && seen.add(currentUrl)) {
    final uri = Uri.tryParse(currentUrl);
    if (uri == null) break;
    final originalUrl = uri.queryParameters['url'];
    if (originalUrl == null || originalUrl.isEmpty) break;
    currentUrl = originalUrl;
  }
  return currentUrl;
}

class MediaItem {
  /// Network URL used for loading. Prefer Lemmy `image_proxy` when the origin
  /// is blocked, but [resolveMediaLoadUrls] may swap in the origin for CDN
  /// thumbs that carry resize query params (proxy often re-fetches full-res).
  final String url;

  /// Original API / markdown URL before [resolveMediaLoadUrls] (for strip/dedupe).
  final String rawUrl;
  final MediaType type;
  final VideoType? videoType;
  final String? thumbnailUrl;

  /// Alternate URL to try when [url] fails to load/decode (e.g. proxy ↔ origin).
  final String? fallbackUrl;

  MediaItem({
    required this.url,
    required this.type,
    this.videoType,
    this.thumbnailUrl,
    this.fallbackUrl,
    /// Pre-resolve source (body / post.url). Defaults to [url].
    String? sourceUrl,
  }) : rawUrl = sourceUrl ?? url;

  bool get isVideo => type == MediaType.video;
  bool get isImage => type == MediaType.image;
}

/// CDN / CMS resize query keys that WordPress, Fastly, etc. honor on the origin
/// but that Lemmy's `image_proxy` fetch often does not apply (so the proxy stores
/// a full-resolution AVIF while `image_details` still reports the og:image size).
bool _hasImageResizeQuery(Uri uri) {
  for (final key in uri.queryParameters.keys) {
    switch (key.toLowerCase()) {
      case 'w':
      case 'h':
      case 'width':
      case 'height':
      case 'fit':
      case 'resize':
      case 'crop':
      case 'trim':
      case 'quality':
      case 'q':
      case 'auto':
        return true;
    }
  }
  return false;
}

/// Pick primary + fallback load URLs for a Lemmy media URL.
///
/// - When the nested origin has resize query params, prefer the origin (small
///   JPEG/WebP) and keep the proxy as fallback for hotlink blocks.
/// - Otherwise keep the proxy first (smaller AVIF, works when origin is 403/451)
///   and use the origin as a decode/load fallback.
({String url, String? fallbackUrl}) resolveMediaLoadUrls(String url) {
  if (!url.contains('image_proxy')) {
    return (url: url, fallbackUrl: null);
  }
  final origin = cleanImageProxyUrl(url);
  if (origin == url || !isSafeNetworkMediaUrl(origin)) {
    return (url: url, fallbackUrl: null);
  }
  final originUri = Uri.tryParse(origin);
  if (originUri != null &&
      _hasImageResizeQuery(originUri) &&
      isImageUrl(origin)) {
    return (url: origin, fallbackUrl: url);
  }
  return (url: url, fallbackUrl: origin);
}

MediaItem _imageMediaItem(String preferredUrl, {String? thumbnailUrl}) {
  final resolved = resolveMediaLoadUrls(preferredUrl);
  return MediaItem(
    url: resolved.url,
    type: MediaType.image,
    thumbnailUrl: thumbnailUrl,
    fallbackUrl: resolved.fallbackUrl,
    sourceUrl: preferredUrl,
  );
}

bool isImageContentType(String? contentType) {
  if (contentType == null || contentType.isEmpty) return false;
  return contentType.toLowerCase().startsWith('image/');
}

bool isImageUrl(String url) {
  if (!isSafeNetworkMediaUrl(url)) return false;
  // Detect via nested origin when the public URL is an image_proxy endpoint.
  final candidate = cleanImageProxyUrl(url);
  final uri = Uri.tryParse(candidate);
  if (uri == null) return false;
  final path = uri.path.toLowerCase();
  return path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.webp') ||
      path.endsWith('.gif') ||
      path.endsWith('.heic') ||
      path.endsWith('.avif');
}

bool isNativeVideoUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !isSafeNetworkMediaUrl(url)) return false;
  final path = uri.path.toLowerCase();
  return path.endsWith('.mp4') ||
      path.endsWith('.m3u8') ||
      path.endsWith('.mov') ||
      path.endsWith('.webm') ||
      path.endsWith('.mkv') ||
      path.endsWith('.3gp') ||
      path.endsWith('.avi');
}

bool isYouTubeUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https') return false;
  final host = uri.host.toLowerCase();
  return host == 'youtube.com' ||
      host == 'www.youtube.com' ||
      host == 'm.youtube.com' ||
      host == 'youtu.be';
}

/// Only load HTTPS media. This avoids clear-text tracking and prevents posts
/// from making the device request localhost/private HTTP services.
bool isSafeNetworkMediaUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return false;
  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host.endsWith('.localhost')) return false;
  if (RegExp(r'^127(?:\.\d{1,3}){3}$').hasMatch(host) ||
      RegExp(r'^10(?:\.\d{1,3}){3}$').hasMatch(host) ||
      RegExp(r'^192\.168(?:\.\d{1,3}){2}$').hasMatch(host) ||
      RegExp(r'^172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2}$').hasMatch(host)) {
    return false;
  }
  return true;
}

bool isVideoUrl(String url) {
  return isNativeVideoUrl(url) || isYouTubeUrl(url);
}

List<MediaItem> extractMarkdownMedia(String source) {
  final seen = <String>{};
  final items = <MediaItem>[];

  // Match markdown image syntax: ![alt](url)
  // Match markdown link syntax: [text](url)
  // Match raw urls
  final rawUrlRegex = RegExp(r'(https?://[^\s)<>"]+)');
  final allMatches = rawUrlRegex.allMatches(source);

  for (final match in allMatches) {
    final url = match.group(1)!;
    if (seen.contains(url)) continue;
    if (!isSafeNetworkMediaUrl(url)) continue;

    final isImg = isImageUrl(url);
    final isVid = isVideoUrl(url);

    // Check if it's inside markdown image syntax `![alt](url)`. The alt text
    // is our durable type marker for pict-rs URLs, which intentionally have no
    // filename extension after upload.
    bool isInsideImageMarkdown = false;
    bool isVideoMarkdown = false;
    final startIdx = match.start;
    if (startIdx >= 2 && source.substring(startIdx - 2, startIdx) == '](') {
      final bracketIdx = source.lastIndexOf('[', startIdx);
      if (bracketIdx != -1 && bracketIdx > 0 && source[bracketIdx - 1] == '!') {
        isInsideImageMarkdown = true;
        isVideoMarkdown =
            source
                .substring(bracketIdx + 1, startIdx - 2)
                .trim()
                .toLowerCase() ==
            'video';
      }
    }

    if (isInsideImageMarkdown || isImg || isVid) {
      seen.add(url);
      if (isVid || isVideoMarkdown) {
        final vidType = isYouTubeUrl(url)
            ? VideoType.youtube
            : VideoType.native;
        items.add(
          MediaItem(
            url: url,
            type: MediaType.video,
            videoType: vidType,
            thumbnailUrl: vidType == VideoType.youtube
                ? getYouTubeThumbnail(url)
                : null,
          ),
        );
      } else {
        items.add(_imageMediaItem(url));
      }
    }
  }
  return items;
}

String? getYouTubeThumbnail(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !isYouTubeUrl(url)) return null;
  String? id;
  if (uri.host.toLowerCase() == 'youtu.be') {
    id = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
  } else if (uri.path == '/watch') {
    id = uri.queryParameters['v'];
  } else if (uri.pathSegments.length >= 2 &&
      (uri.pathSegments.first == 'shorts' ||
          uri.pathSegments.first == 'embed')) {
    id = uri.pathSegments[1];
  }
  if (id == null || !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id)) return null;
  return 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}

/// Dedupe key for media URLs: unwrap `image_proxy` so proxy vs origin match.
String mediaUrlDedupeKey(String url) => cleanImageProxyUrl(url);

void _rememberMediaUrl(Set<String> seen, String url) {
  seen.add(url);
  seen.add(mediaUrlDedupeKey(url));
}

bool _alreadyHaveMediaUrl(Set<String> seen, String url) =>
    seen.contains(url) || seen.contains(mediaUrlDedupeKey(url));

void _rememberItem(Set<String> seen, MediaItem item) {
  _rememberMediaUrl(seen, item.url);
  _rememberMediaUrl(seen, item.rawUrl);
  if (item.fallbackUrl != null) _rememberMediaUrl(seen, item.fallbackUrl!);
  if (item.thumbnailUrl != null) _rememberMediaUrl(seen, item.thumbnailUrl!);
}

bool _haveItem(Set<String> seen, MediaItem item) =>
    _alreadyHaveMediaUrl(seen, item.url) ||
    _alreadyHaveMediaUrl(seen, item.rawUrl) ||
    (item.fallbackUrl != null &&
        _alreadyHaveMediaUrl(seen, item.fallbackUrl!)) ||
    (item.thumbnailUrl != null &&
        _alreadyHaveMediaUrl(seen, item.thumbnailUrl!));

List<MediaItem> extractPostMedia(PostView postView) {
  final post = postView.post;
  final seen = <String>{};
  final items = <MediaItem>[];

  // 1. Primary media from post.url or post.embedVideoUrl
  final primaryUrl = post.embedVideoUrl ?? post.url;
  if (primaryUrl != null && primaryUrl.isNotEmpty) {
    if (isVideoUrl(primaryUrl)) {
      final vidType = isYouTubeUrl(primaryUrl)
          ? VideoType.youtube
          : VideoType.native;
      final item = MediaItem(
        url: primaryUrl,
        type: MediaType.video,
        videoType: vidType,
        thumbnailUrl:
            post.thumbnailUrl ??
            (vidType == VideoType.youtube
                ? getYouTubeThumbnail(primaryUrl)
                : null),
        sourceUrl: primaryUrl,
      );
      _rememberItem(seen, item);
      items.add(item);
    } else if (isSafeNetworkMediaUrl(primaryUrl) &&
        (isImageUrl(primaryUrl) || isImageContentType(post.urlContentType))) {
      final resolved = resolveMediaLoadUrls(primaryUrl);
      // Thumbnail only as progressive layer when it is a distinct asset.
      String? thumb = post.thumbnailUrl;
      if (thumb != null) {
        final thumbKey = mediaUrlDedupeKey(thumb);
        final sameAsPrimary = thumbKey == mediaUrlDedupeKey(primaryUrl) ||
            thumbKey == mediaUrlDedupeKey(resolved.url) ||
            (resolved.fallbackUrl != null &&
                thumbKey == mediaUrlDedupeKey(resolved.fallbackUrl!));
        if (sameAsPrimary) thumb = null;
      }
      final item = MediaItem(
        url: resolved.url,
        type: MediaType.image,
        thumbnailUrl: thumb,
        fallbackUrl: resolved.fallbackUrl,
        sourceUrl: primaryUrl,
      );
      _rememberItem(seen, item);
      items.add(item);
    }
  }

  // 2. Fallback thumbnail as image if no video was added yet and thumbnail is present
  if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty) {
    final hasVideo = items.any((i) => i.isVideo);
    if (!hasVideo &&
        isSafeNetworkMediaUrl(post.thumbnailUrl!) &&
        !_alreadyHaveMediaUrl(seen, post.thumbnailUrl!)) {
      final thumbItem = _imageMediaItem(post.thumbnailUrl!);
      if (!_haveItem(seen, thumbItem)) {
        _rememberItem(seen, thumbItem);
        items.add(thumbItem);
      }
    }
  }

  // 3. Extra media from body markdown (skip if already primary / thumb)
  if (post.body != null && post.body!.isNotEmpty) {
    for (final item in extractMarkdownMedia(post.body!)) {
      if (_haveItem(seen, item)) continue;
      _rememberItem(seen, item);
      items.add(item);
    }
  }

  return items;
}

/// Remove markdown image (and video) embeds that were promoted to [media]
/// frames — so body text does not show the same picture twice.
///
/// Matches proxy ↔ origin and primary ↔ fallback via [mediaUrlDedupeKey].
String stripMarkdownMedia(String source, List<MediaItem> media) {
  if (source.isEmpty || media.isEmpty) return source.trim();

  final keys = <String>{};
  void addKey(String? url) {
    if (url == null || url.isEmpty) return;
    keys.add(url);
    keys.add(mediaUrlDedupeKey(url));
  }

  for (final item in media) {
    addKey(item.url);
    addKey(item.rawUrl);
    addKey(item.thumbnailUrl);
    addKey(item.fallbackUrl);
  }

  // ![alt](url) — including pict-rs video markers.
  final stripped = source.replaceAllMapped(
    RegExp(r'!\[.*?\]\((https?://[^\s)]+)\)'),
    (match) {
      final url = match.group(1)!;
      if (keys.contains(url) || keys.contains(mediaUrlDedupeKey(url))) {
        return '';
      }
      return match.group(0)!;
    },
  );

  // Collapse leftover blank lines from removed image blocks.
  return stripped
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
