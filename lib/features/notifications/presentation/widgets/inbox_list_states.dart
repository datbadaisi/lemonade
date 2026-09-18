import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/shared/widgets/skeleton/skeleton.dart';

/// Empty inbox / messages list (pull-to-refresh compatible).
class InboxEmptyView extends StatelessWidget {
  const InboxEmptyView({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Align(
            alignment: const Alignment(0.0, -0.2),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Error + retry for either inbox tab.
class InboxErrorView extends StatelessWidget {
  const InboxErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    MingCuteIcons.mgc_alert_line,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'An error occurred: $error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onRetry,
                    child: const Text(
                      'Retry',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationSkeletonList extends StatelessWidget {
  const NotificationSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: 8,
      itemBuilder: (_, _) => const NotificationTileSkeleton(),
    );
  }
}

class ConversationSkeletonList extends StatelessWidget {
  const ConversationSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: 8,
      itemBuilder: (_, _) => const ConversationTileSkeleton(),
    );
  }
}
