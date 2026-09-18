import 'package:flutter/material.dart';

/// Shared confirm dialog for destructive / restore actions on post detail.
Future<bool> showPostDetailConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  Color confirmColor = const Color(0xFFE53935),
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: Text(
        body,
        style: const TextStyle(fontSize: 13, color: Color(0xFF525252)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              fontSize: 13,
              color: confirmColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result == true;
}

/// Report reason dialog; returns trimmed reason or null if cancelled/empty.
Future<String?> showPostDetailReportDialog({
  required BuildContext context,
  required String title,
  required String prompt,
}) async {
  final textController = TextEditingController();
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            prompt,
            style: const TextStyle(fontSize: 13, color: Color(0xFF525252)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textController,
            style: const TextStyle(fontSize: 13, color: Color(0xFF000000)),
            decoration: const InputDecoration(
              hintText: 'Enter reason...',
              hintStyle: TextStyle(fontSize: 13, color: Color(0x66525252)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF000000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            'Report',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFE53935),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  final reason = textController.text.trim();
  textController.dispose();
  if (confirm != true) return null;
  if (reason.isEmpty) return '';
  return reason;
}
