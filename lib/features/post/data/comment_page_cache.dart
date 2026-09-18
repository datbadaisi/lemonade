import 'package:bluerum/shared/models/comment.dart';

/// Small in-memory cache for the first page of a post's comments.
///
/// Post detail is frequently opened and closed while browsing a feed. Keeping
/// this page in memory makes a revisit render immediately, while pull-to-
/// refresh remains the explicit way to request fresh data.
final class CommentPageCache {
  CommentPageCache({
    this.maxEntries = 20,
    this.ttl = const Duration(minutes: 5),
  });

  final int maxEntries;
  final Duration ttl;
  final Map<_CommentPageCacheKey, _CommentPageCacheEntry> _entries = {};

  /// Whether a non-expired entry exists for this key (does not promote LRU).
  bool has({
    required int postId,
    required int? threadRootId,
    required CommentSortType sort,
    required int sessionId,
  }) {
    final key = _CommentPageCacheKey(postId, threadRootId, sort, sessionId);
    final entry = _entries[key];
    if (entry == null) return false;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _entries.remove(key);
      return false;
    }
    return true;
  }

  CommentPageCacheEntry? read({
    required int postId,
    required int? threadRootId,
    required CommentSortType sort,
    required int sessionId,
  }) {
    final key = _CommentPageCacheKey(postId, threadRootId, sort, sessionId);
    final entry = _entries.remove(key);
    if (entry == null || DateTime.now().difference(entry.cachedAt) > ttl) {
      return null;
    }

    // Reinsert so recently viewed posts are retained when the cache is full.
    _entries[key] = entry;
    return CommentPageCacheEntry(
      comments: List.unmodifiable(entry.comments),
      parentComment: entry.parentComment,
      hasMore: entry.hasMore,
    );
  }

  void write({
    required int postId,
    required int? threadRootId,
    required CommentSortType sort,
    required int sessionId,
    required List<CommentView> comments,
    required CommentView? parentComment,
    required bool hasMore,
  }) {
    final key = _CommentPageCacheKey(postId, threadRootId, sort, sessionId);
    _entries.remove(key);
    _entries[key] = _CommentPageCacheEntry(
      comments: List.unmodifiable(comments),
      parentComment: parentComment,
      hasMore: hasMore,
      cachedAt: DateTime.now(),
    );
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() => _entries.clear();
}

/// Process-wide cache shared by post detail screens.
final sharedCommentPageCache = CommentPageCache();

class CommentPageCacheEntry {
  const CommentPageCacheEntry({
    required this.comments,
    required this.parentComment,
    required this.hasMore,
  });

  final List<CommentView> comments;
  final CommentView? parentComment;
  final bool hasMore;
}

final class _CommentPageCacheEntry extends CommentPageCacheEntry {
  const _CommentPageCacheEntry({
    required super.comments,
    required super.parentComment,
    required super.hasMore,
    required this.cachedAt,
  });

  final DateTime cachedAt;
}

final class _CommentPageCacheKey {
  const _CommentPageCacheKey(
    this.postId,
    this.threadRootId,
    this.sort,
    this.sessionId,
  );

  final int postId;
  final int? threadRootId;
  final CommentSortType sort;
  final int sessionId;

  @override
  bool operator ==(Object other) =>
      other is _CommentPageCacheKey &&
      postId == other.postId &&
      threadRootId == other.threadRootId &&
      sort == other.sort &&
      sessionId == other.sessionId;

  @override
  int get hashCode => Object.hash(postId, threadRootId, sort, sessionId);
}
