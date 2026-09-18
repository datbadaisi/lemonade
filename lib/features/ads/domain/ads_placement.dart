/// Pure helpers for inserting ads into linear lists (home feed).
///
/// Pattern with [postsPerAd] = 6:
/// `P P P P P P A P P P P P P A ...`
/// Ad only appears after a complete group of [postsPerAd] posts.
library;

/// Total list length when [postCount] posts are mixed with ads.
int feedItemCount({
  required int postCount,
  required int postsPerAd,
  required bool showAds,
}) {
  if (!showAds || postsPerAd <= 0 || postCount <= 0) return postCount;
  return postCount + postCount ~/ postsPerAd;
}

/// Whether the list [index] is an ad slot.
bool isFeedAdAt({
  required int index,
  required int postCount,
  required int postsPerAd,
  required bool showAds,
}) {
  if (!showAds || postsPerAd <= 0 || postCount <= 0) return false;
  final maxAds = postCount ~/ postsPerAd;
  if (maxAds <= 0) return false;
  final group = postsPerAd + 1;
  if ((index + 1) % group != 0) return false;
  final adOrdinal = (index + 1) ~/ group; // 1-based
  return adOrdinal >= 1 && adOrdinal <= maxAds;
}

/// Maps a feed list index to a post index. Only valid when [isFeedAdAt] is false.
int feedPostIndex({
  required int listIndex,
  required int postsPerAd,
  required bool showAds,
}) {
  if (!showAds || postsPerAd <= 0) return listIndex;
  final group = postsPerAd + 1;
  final adsBefore = listIndex ~/ group;
  return listIndex - adsBefore;
}

/// Builds display entries for a flattened comment tree (DFS order).
///
/// [isRootAt] marks root (depth-0) rows. Ads are counted by root, but
/// inserted **after the whole root thread** (root + all nested replies),
/// never between a parent and its children:
///
/// ```
/// Root9
///   Reply9.1
///   Reply9.2
/// [Ad]          ← here, not under Root9 before its replies
/// Root10
/// ```
List<CommentDisplayEntry> buildCommentDisplayEntries({
  required int rowCount,
  required bool Function(int rowIndex) isRootAt,
  required int rootsPerAd,
  required bool showAds,
}) {
  if (rowCount <= 0) return const [];
  if (!showAds || rootsPerAd <= 0) {
    return [
      for (var i = 0; i < rowCount; i++) CommentDisplayEntry.comment(i),
    ];
  }

  // Root start indices in DFS order: thread k runs [root[k], root[k+1]).
  final rootStarts = <int>[];
  for (var i = 0; i < rowCount; i++) {
    if (isRootAt(i)) rootStarts.add(i);
  }

  // After which row index to insert an ad (end of every Nth root thread).
  final adAfterRow = <int>{};
  for (var k = 0; k < rootStarts.length; k++) {
    final ordinal = k + 1; // 1-based root count
    if (ordinal % rootsPerAd != 0) continue;
    final threadEnd = k + 1 < rootStarts.length
        ? rootStarts[k + 1] - 1
        : rowCount - 1;
    adAfterRow.add(threadEnd);
  }

  final out = <CommentDisplayEntry>[];
  var adSlot = 0;
  for (var i = 0; i < rowCount; i++) {
    out.add(CommentDisplayEntry.comment(i));
    if (adAfterRow.contains(i)) {
      out.add(CommentDisplayEntry.ad(adSlot++));
    }
  }
  return out;
}

/// One slot in the comment ListView (comment row or in-feed ad).
final class CommentDisplayEntry {
  const CommentDisplayEntry._({this.rowIndex, this.adSlot})
      : assert(
          (rowIndex != null) ^ (adSlot != null),
          'Exactly one of rowIndex or adSlot must be set',
        );

  const CommentDisplayEntry.comment(int rowIndex)
      : this._(rowIndex: rowIndex, adSlot: null);

  const CommentDisplayEntry.ad(int adSlot)
      : this._(rowIndex: null, adSlot: adSlot);

  final int? rowIndex;
  final int? adSlot;

  bool get isAd => adSlot != null;
}
