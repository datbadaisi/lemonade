import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/features/post/presentation/comment_list_memory.dart';
import 'package:bluerum/features/post/presentation/comment_thread_flatten.dart';

// Re-export so existing call sites keep working.
export 'package:bluerum/core/utils/time_ago.dart'
    show formatCommentTimeAgo, clearCommentTimeAgoCache;

const double kCommentListFooterHeight = 56;
const double kCommentListHeaderFallback = 280;

/// Pure helpers for scroll-offset / jump estimates.
///
/// **Not** used as ListView [itemExtentBuilder]: that API *forces* child
/// height and wrong estimates clip variable markdown/media. Prefer measured
/// heights + VM estimates for jump/precache only.
double estimateCommentRowHeight({
  required CommentBodyVm bodyVm,
  required double contentWidth,
  double? measuredHeight,
  double depthIndent = 0,
  double maxMediaHeight = 440,
}) {
  if (measuredHeight != null && measuredHeight > 0) {
    return measuredHeight;
  }
  final w = (contentWidth - depthIndent).clamp(48.0, contentWidth);
  return bodyVm.estimateListHeight(
    contentWidth: w,
    maxMediaHeight: maxMediaHeight,
  );
}

/// Scroll offset to the start of list item [listIndex] (0 = header).
double estimateListOffsetForIndex({
  required int listIndex,
  required int leadingCount,
  required List<CommentDisplayEntry> body,
  required List<CommentFlatRow> rows,
  required CommentBodyVmStore bodyVms,
  required CommentListMemoryPolicy memory,
  required double contentWidth,
  double headerHeight = kCommentListHeaderFallback,
  double maxMediaHeight = 440,
}) {
  if (listIndex <= 0) return 0;

  var offset = headerHeight;
  if (listIndex < leadingCount) return 0;

  final targetBody = listIndex - leadingCount;
  final upto = targetBody.clamp(0, body.length);

  for (var i = 0; i < upto; i++) {
    final e = body[i];
    final rowIndex = e.rowIndex;
    if (rowIndex < 0 || rowIndex >= rows.length) {
      offset += memory.averageHeight();
      continue;
    }
    final row = rows[rowIndex];
    final id = row.cv.comment.id;
    final measured = memory.heightOf(id);
    final vm =
        bodyVms.peek(id) ??
        bodyVms.obtain(commentId: id, content: row.cv.comment.content);
    offset += estimateCommentRowHeight(
      bodyVm: vm,
      contentWidth: contentWidth,
      measuredHeight: measured,
      depthIndent: row.depth * 13.0,
      maxMediaHeight: maxMediaHeight,
    );
  }
  return offset;
}
