import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:bluerum/core/utils/media_utils.dart';

/// How the list paints this comment body (stable from first frame — no settle swap).
enum CommentBodyPaintKind {
  /// Cheap [Text].
  plain,

  /// Precomputed link segments → [Text.rich] (blue + tap, no MarkdownBody).
  linksOnly,

  /// Full [BluerumMarkdown] (bold/code/spoiler/lists…).
  fullRich,
}

/// One run of plain text or a tappable link for [CommentBodyPaintKind.linksOnly].
final class CommentBodySegment {
  const CommentBodySegment.plain(this.text) : href = null;
  const CommentBodySegment.link(this.text, this.href);

  final String text;
  final String? href;

  bool get isLink => href != null && href!.isNotEmpty;
}

/// Precomputed comment body for list paint — pure work **once** per content
/// version, not on every [ListView] build / recycle.
///
/// Plane split (same idea as [PostCardVm] on home feed):
/// - **Data plane**: [CommentBodyVmStore] builds/caches these off the fling path.
/// - **Render plane**: tiles bind [listPlain] / [linkSegments] / [markdownSource]
///   by [paintKind] — **no Text→Markdown swap after scroll settle**.
final class CommentBodyVm {
  const CommentBodyVm({
    required this.commentId,
    required this.contentKey,
    required this.listPlain,
    required this.markdownSource,
    required this.media,
    required this.paintKind,
    required this.linkSegments,
    required this.estimatedTextLines,
  });

  final int commentId;
  final String contentKey;
  final String listPlain;
  final String markdownSource;
  final List<MediaItem> media;
  final CommentBodyPaintKind paintKind;

  /// Non-empty only when [paintKind] == [CommentBodyPaintKind.linksOnly].
  final List<CommentBodySegment> linkSegments;

  /// Rough line count for height estimates (list virtualization).
  final int estimatedTextLines;

  /// Back-compat: any non-plain paint.
  bool get needsRich => paintKind != CommentBodyPaintKind.plain;

  bool get hasText => listPlain.isNotEmpty || markdownSource.trim().isNotEmpty;
  bool get hasMedia => media.isNotEmpty;
  bool get isMultipleMedia => media.length >= 2;

  /// Estimated row height (author + body + optional media + action bar).
  double estimateListHeight({
    required double contentWidth,
    double maxMediaHeight = 280,
    double authorRow = 36,
    double actionBar = 40,
    double mediaGap = 8,
    double lineHeight = 13 * 1.35,
  }) {
    var h = authorRow + actionBar;
    if (hasText) {
      final lines = estimatedTextLines.clamp(1, 12);
      h += lines * lineHeight + 8;
    }
    if (hasMedia && contentWidth > 0) {
      // Default 16:9 until aspect cache fills; cap like CommentMediaWidget.
      final mediaH = (contentWidth / (16 / 9)).clamp(48.0, maxMediaHeight);
      h += mediaGap + mediaH;
    }
    return h;
  }

  /// True when content needs more than plain text (links or markup).
  static bool looksLikeMarkup(String source) {
    if (source.isEmpty) return false;
    if (source.contains('http://') || source.contains('https://')) return true;
    if (source.contains('](')) return true;
    if (_looksLikeFullMarkup(source)) return true;
    return false;
  }

  /// Anything that needs [BluerumMarkdown] (not bare-URL Text.rich).
  ///
  /// Markdown links (`[label](url)`) always go fullRich: relative/community
  /// paths, titles, and mixed markup are incomplete in [buildLinkSegments] and
  /// otherwise paint as raw `[label](url)`.
  static bool _looksLikeFullMarkup(String source) {
    // Markdown / image links — full parser handles relative + absolute URLs.
    if (source.contains('](')) return true;
    // Emphasis
    if (source.contains('**') || source.contains('__')) return true;
    if (source.contains('~~')) return true; // strikethrough
    if (source.contains('```') || source.contains('`')) return true;
    if (source.contains('> ')) return true;
    if (source.contains('\n- ') ||
        source.contains('\n* ') ||
        source.contains('\n1.')) {
      return true;
    }
    // Lemmy spoiler fence (any casing)
    if (source.contains(':::')) return true;
    // HTML spoiler / details (some instances emit HTML)
    if (source.toLowerCase().contains('<details')) return true;
    if (source.contains('\n#') || source.startsWith('#')) return true;
    // Tables
    if (source.contains('|') && source.contains('\n')) {
      if (RegExp(r'\|.+\|').hasMatch(source)) return true;
    }
    // Single * or _ italic — cheap heuristic; prefer fullRich if ambiguous.
    if (source.contains('*') && !source.contains('http')) {
      if (RegExp(r'(?<!\*)\*(?!\*)').hasMatch(source)) return true;
    }
    if (source.contains('_') && !source.contains('http')) {
      if (RegExp(r'(?<!_)_(?!_)').hasMatch(source)) return true;
    }
    return false;
  }

  /// Bare http(s) URLs only — no markdown link syntax.
  static bool _looksLikeLinksOnly(String source) {
    if (_looksLikeFullMarkup(source)) return false;
    return source.contains('http://') || source.contains('https://');
  }

  /// Split [source] into plain + link runs (bare https?://… only).
  ///
  /// Markdown `[label](url)` is handled by [CommentBodyPaintKind.fullRich].
  static List<CommentBodySegment> buildLinkSegments(String source) {
    if (source.isEmpty) return const [];

    final pattern = RegExp(
      r'https?:\/\/[^\s<>\[\]()]+',
      caseSensitive: false,
    );

    final out = <CommentBodySegment>[];
    var cursor = 0;
    for (final m in pattern.allMatches(source)) {
      if (m.start > cursor) {
        final plain = source.substring(cursor, m.start);
        if (plain.isNotEmpty) out.add(CommentBodySegment.plain(plain));
      }
      final url = m.group(0)!;
      // Trim trailing punctuation often stuck to bare URLs.
      var clean = url;
      while (clean.isNotEmpty &&
          (clean.endsWith('.') ||
              clean.endsWith(',') ||
              clean.endsWith(';') ||
              clean.endsWith('!') ||
              clean.endsWith('?') ||
              clean.endsWith(')') ||
              clean.endsWith(']'))) {
        clean = clean.substring(0, clean.length - 1);
      }
      if (clean.isNotEmpty) {
        out.add(CommentBodySegment.link(clean, clean));
        if (clean.length < url.length) {
          out.add(CommentBodySegment.plain(url.substring(clean.length)));
        }
      }
      cursor = m.end;
    }
    if (cursor < source.length) {
      final tail = source.substring(cursor);
      if (tail.isNotEmpty) out.add(CommentBodySegment.plain(tail));
    }
    if (out.isEmpty) return [CommentBodySegment.plain(source)];
    return List<CommentBodySegment>.unmodifiable(out);
  }

  static int _estimateLines(String text) {
    if (text.isEmpty) return 0;
    // ~42 chars/line at 13px on a typical phone content width.
    const charsPerLine = 42;
    var lines = 0;
    for (final para in text.split('\n')) {
      if (para.isEmpty) {
        lines += 1;
      } else {
        lines += (para.length / charsPerLine).ceil().clamp(1, 20);
      }
    }
    return lines.clamp(1, 12);
  }

  factory CommentBodyVm.fromContent({
    required int commentId,
    required String content,
  }) {
    final key = contentKeyFor(commentId, content);
    if (content.isEmpty) {
      return CommentBodyVm(
        commentId: commentId,
        contentKey: key,
        listPlain: '',
        markdownSource: '',
        media: const [],
        paintKind: CommentBodyPaintKind.plain,
        linkSegments: const [],
        estimatedTextLines: 0,
      );
    }

    final media = List<MediaItem>.unmodifiable(extractMarkdownMedia(content));
    final stripped =
        media.isEmpty ? content : stripMarkdownMedia(content, media);
    final trimmed = stripped.trim();

    CommentBodyPaintKind kind;
    if (trimmed.isEmpty) {
      kind = CommentBodyPaintKind.plain;
    } else if (_looksLikeFullMarkup(trimmed)) {
      kind = CommentBodyPaintKind.fullRich;
    } else if (_looksLikeLinksOnly(trimmed)) {
      kind = CommentBodyPaintKind.linksOnly;
    } else {
      kind = CommentBodyPaintKind.plain;
    }

    final String listPlain;
    if (trimmed.isEmpty) {
      listPlain = '';
    } else if (kind == CommentBodyPaintKind.fullRich) {
      listPlain = markdownToPlainText(stripped);
    } else if (kind == CommentBodyPaintKind.linksOnly) {
      // Bare URLs only — display text is already readable.
      listPlain = trimmed;
    } else {
      listPlain = trimmed;
    }

    final segments = kind == CommentBodyPaintKind.linksOnly
        ? buildLinkSegments(trimmed)
        : const <CommentBodySegment>[];

    return CommentBodyVm(
      commentId: commentId,
      contentKey: key,
      listPlain: listPlain,
      markdownSource: stripped,
      media: media,
      paintKind: kind,
      linkSegments: segments,
      estimatedTextLines: _estimateLines(
        listPlain.isNotEmpty ? listPlain : trimmed,
      ),
    );
  }

  static String contentKeyFor(int commentId, String content) =>
      '$commentId|${content.length}|${content.hashCode}';
}

/// Screen-scoped (or shared) cache of [CommentBodyVm].
final class CommentBodyVmStore {
  CommentBodyVmStore({this.maxEntries = 400});

  final int maxEntries;
  final Map<String, CommentBodyVm> _byKey = {};
  final Map<int, String> _keyById = {};

  int get length => _byKey.length;

  CommentBodyVm obtain({required int commentId, required String content}) {
    final key = CommentBodyVm.contentKeyFor(commentId, content);
    final existing = _byKey[key];
    if (existing != null) return existing;

    final vm = CommentBodyVm.fromContent(commentId: commentId, content: content);
    _put(key, vm);
    return vm;
  }

  void prepareAll(Iterable<({int id, String content})> items) {
    for (final item in items) {
      obtain(commentId: item.id, content: item.content);
    }
  }

  CommentBodyVm? peek(int commentId) {
    final key = _keyById[commentId];
    if (key == null) return null;
    return _byKey[key];
  }

  void retainIds(Set<int> liveIds) {
    if (_keyById.length <= liveIds.length &&
        _keyById.keys.every(liveIds.contains)) {
      return;
    }
    final stale = _keyById.keys.where((id) => !liveIds.contains(id)).toList();
    for (final id in stale) {
      final key = _keyById.remove(id);
      if (key != null) _byKey.remove(key);
    }
  }

  void clear() {
    _byKey.clear();
    _keyById.clear();
  }

  void _put(String key, CommentBodyVm vm) {
    final prevKey = _keyById[vm.commentId];
    if (prevKey != null && prevKey != key) {
      _byKey.remove(prevKey);
    }
    _keyById[vm.commentId] = key;
    _byKey[key] = vm;

    while (_byKey.length > maxEntries) {
      final firstKey = _byKey.keys.first;
      final removed = _byKey.remove(firstKey);
      if (removed != null) {
        if (_keyById[removed.commentId] == firstKey) {
          _keyById.remove(removed.commentId);
        }
      }
    }
  }
}
