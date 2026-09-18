import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

/// Compact single-select bottom sheet used by Home filter sort/type pickers.
Future<void> showOptionPickerBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String selected,
  required ValueChanged<String> onSelected,
  Widget? footer,
}) {
  return showModalBottomSheet<void>(
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
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            ...options.map((option) {
              final sel = selected == option;
              return ListTile(
                leading: Icon(
                  sel
                      ? MingCuteIcons.mgc_check_circle_fill
                      : MingCuteIcons.mgc_round_line,
                  size: 22,
                  color: const Color(0xFF000000),
                ),
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF000000),
                  ),
                ),
                onTap: () {
                  // Pop first so dismiss animation is not racing list reload.
                  Navigator.of(ctx).pop();
                  onSelected(option);
                },
              );
            }),
            ?footer,
          ],
        ),
      ),
    ),
  );
}
