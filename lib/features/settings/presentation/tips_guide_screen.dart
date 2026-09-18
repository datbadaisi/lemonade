import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:bluerum/app/theme/app_colors.dart';

/// Guide to less-obvious gestures and shortcuts in the app.
class TipsGuideScreen extends StatelessWidget {
  const TipsGuideScreen({super.key});

  static const _tips = <_TipItem>[
    _TipItem(
      title: 'Double-tap Home',
      description:
          'On the bottom bar, double-tap the Home tab to jump to the top of the feed and refresh it — same feel as a pull-to-refresh.',
    ),
    _TipItem(
      title: 'Swipe feed left or right',
      description:
          'On the home feed, swipe left for All and right for Subscribed. Subscribed needs you to be logged in.',
    ),
    _TipItem(
      title: 'Tap a comment header',
      description:
          'Tap the author row on a comment to collapse or expand that comment and its replies. Handy for long threads.',
    ),
    _TipItem(
      title: 'Swipe a comment right',
      description:
          'On a reply, swipe right past the threshold to open the parent comment in a sheet so you can re-read the context.',
    ),
    _TipItem(
      title: 'Long-press a comment',
      description:
          'Long-press a comment for more actions — edit or delete your own, or report / block on someone else’s.',
    ),
    _TipItem(
      title: 'Spoilers',
      description:
          'Posts and comments can hide text behind spoiler blocks. Tap the spoiler title to reveal or hide the content.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tips & gestures',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            MingCuteIcons.mgc_left_line,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              'A few shortcuts that are easy to miss. Once you know them, browsing gets faster.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
          for (final tip in _tips)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: Text(
                tip.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  tip.description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TipItem {
  final String title;
  final String description;

  const _TipItem({
    required this.title,
    required this.description,
  });
}
