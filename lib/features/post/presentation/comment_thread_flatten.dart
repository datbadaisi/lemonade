import 'package:bluerum/shared/models/comment.dart';

/// One flattened comment row for list paint (data-plane output).
final class CommentFlatRow {
  const CommentFlatRow({
    required this.cv,
    required this.depth,
    this.isContinueThread = false,
    this.ancestorContinues = const [],
    this.isLastSibling = true,
  });

  final CommentView cv;
  final int depth;
  final bool isContinueThread;
  final List<bool> ancestorContinues;
  final bool isLastSibling;
}

/// Pure DFS flatten of a comment map (collapse-aware, depth-capped).
///
/// Extracted from the detail screen so collapse/rebuild does not need shell
/// chrome code paths — only a new [CommentFlatRow] list.
List<CommentFlatRow> flattenCommentThread({
  required Map<int, CommentView> commentMap,
  required List<int> orderedIds,
  required Set<int> collapsedIds,
  required int maxRenderDepth,
  int? threadDisplayRootId,
}) {
  final rows = <CommentFlatRow>[];
  final childrenOf = <int, List<int>>{};
  final topLevel = <int>[];

  for (final id in orderedIds) {
    final cv = commentMap[id];
    if (cv == null) continue;
    final parentId = cv.comment.parentId;

    if (threadDisplayRootId != null && id == threadDisplayRootId) {
      topLevel.add(id);
      continue;
    }

    if (parentId == null ||
        !commentMap.containsKey(parentId) ||
        (threadDisplayRootId == null && cv.comment.depth <= 1)) {
      topLevel.add(id);
    } else {
      childrenOf.putIfAbsent(parentId, () => []).add(id);
    }
  }

  void walk(List<int> ids, int depth, List<bool> ancestorContinues) {
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      final cv = commentMap[id];
      if (cv == null) continue;

      final isLast = i == ids.length - 1;
      final children = childrenOf[id] ?? const <int>[];
      final hasChildren = children.isNotEmpty;

      if (depth >= maxRenderDepth && hasChildren) {
        rows.add(
          CommentFlatRow(
            cv: cv,
            depth: depth.clamp(0, maxRenderDepth),
            isContinueThread: true,
            ancestorContinues: ancestorContinues,
            isLastSibling: isLast,
          ),
        );
        continue;
      }

      rows.add(
        CommentFlatRow(
          cv: cv,
          depth: depth.clamp(0, maxRenderDepth),
          isContinueThread: false,
          ancestorContinues: ancestorContinues,
          isLastSibling: isLast,
        ),
      );

      if (!collapsedIds.contains(id) && hasChildren) {
        final childAncestors = depth == 0
            ? const <bool>[]
            : <bool>[...ancestorContinues, !isLast];
        walk(children, depth + 1, childAncestors);
      }
    }
  }

  walk(topLevel, 0, const []);
  return rows;
}

/// Build rowIndex → list body index map (ads interleaved later by placement).
Map<int, int> commentIdToRowIndex(List<CommentFlatRow> rows) {
  final map = <int, int>{};
  for (var i = 0; i < rows.length; i++) {
    map[rows[i].cv.comment.id] = i;
  }
  return map;
}
