import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/shared/models/comment.dart';

/// "More" actions sheet for the post-detail app bar.
void showPostDetailMoreSheet({
  required BuildContext context,
  required bool isMyPost,
  required bool isDeleted,
  required bool isSaved,
  required String sortLabel,
  required VoidCallback onEdit,
  required VoidCallback onDeleteOrRestore,
  required VoidCallback onToggleSave,
  required VoidCallback onCrossPost,
  required VoidCallback onCopyLink,
  required VoidCallback onSort,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            if (isMyPost && !isDeleted) ...[
              ListTile(
                leading: const Icon(
                  MingCuteIcons.mgc_pencil_2_line,
                  size: 22,
                  color: Color(0xFF000000),
                ),
                title: const Text(
                  'Edit post',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF000000),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit();
                },
              ),
            ],
            if (isMyPost) ...[
              ListTile(
                leading: Icon(
                  isDeleted
                      ? MingCuteIcons.mgc_refresh_2_line
                      : MingCuteIcons.mgc_delete_2_line,
                  size: 22,
                  color: isDeleted
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                ),
                title: Text(
                  isDeleted ? 'Undelete post' : 'Delete post',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDeleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onDeleteOrRestore();
                },
              ),
            ],
            ListTile(
              leading: Icon(
                isSaved
                    ? MingCuteIcons.mgc_bookmark_fill
                    : MingCuteIcons.mgc_bookmark_line,
                size: 22,
                color: const Color(0xFF000000),
              ),
              title: Text(
                isSaved ? 'Unsave' : 'Save',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onToggleSave();
              },
            ),
            ListTile(
              leading: const Icon(
                MingCuteIcons.mgc_transfer_horizontal_line,
                size: 22,
                color: Color(0xFF000000),
              ),
              title: const Text(
                'Cross-post',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onCrossPost();
              },
            ),
            ListTile(
              leading: const Icon(
                MingCuteIcons.mgc_link_2_line,
                size: 22,
                color: Color(0xFF000000),
              ),
              title: const Text(
                'Copy link',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onCopyLink();
              },
            ),
            ListTile(
              leading: const Icon(
                MingCuteIcons.mgc_sort_ascending_line,
                size: 22,
                color: Color(0xFF000000),
              ),
              title: const Text(
                'Sort comments',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sortLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF525252),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    MingCuteIcons.mgc_right_line,
                    size: 16,
                    color: Color(0xFF525252),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(ctx);
                onSort();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Sort picker for comment list.
void showPostDetailSortSheet({
  required BuildContext context,
  required CommentSortType current,
  required ValueChanged<CommentSortType> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(),
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort comments',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            ...CommentSortType.values.map((s) {
              final sel = s == current;
              return ListTile(
                leading: Icon(
                  sel
                      ? MingCuteIcons.mgc_check_circle_fill
                      : MingCuteIcons.mgc_round_line,
                  size: 22,
                  color: const Color(0xFF000000),
                ),
                title: Text(
                  s.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF000000),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSelected(s);
                },
              );
            }),
          ],
        ),
      ),
    ),
  );
}

Widget _handle() {
  return Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFE0E0E0),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
