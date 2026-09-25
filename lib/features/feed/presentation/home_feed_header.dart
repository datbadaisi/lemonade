import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/features/feed/data/feed_view_settings.dart';
import 'package:bluerum/features/shell/presentation/shell_chrome.dart';
import 'package:bluerum/shared/widgets/filters/option_picker_bottom_sheet.dart';

/// Sliding Home app bar title ("Lemonade") with feed-type color animation.
class HomeFeedHeader extends StatelessWidget {
  const HomeFeedHeader({
    super.key,
    required this.topInset,
    required this.titleAnimController,
    required this.titleScale,
    required this.titleColor,
    required this.onTitleTap,
    required this.viewMode,
    required this.onViewModeSelected,
    required this.lifetimeOwned,
  });

  final double topInset;
  final AnimationController titleAnimController;
  final Animation<double> titleScale;
  final Color titleColor;
  final VoidCallback onTitleTap;
  final FeedViewMode viewMode;
  final ValueChanged<FeedViewMode> onViewModeSelected;
  final bool lifetimeOwned;

  static const Color cardBg = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    const headerHeight = ShellChrome.chromeHeight;

    return Stack(
      children: [
        Positioned(
          top: topInset,
          left: 0,
          right: 0,
          child: ListenableBuilder(
            listenable: ShellChrome.instance.hidePixels,
            builder: (context, child) {
              final hide = ShellChrome.instance.hidePixels.value.clamp(
                0.0,
                headerHeight,
              );
              return IgnorePointer(
                ignoring: hide >= headerHeight - 0.5,
                child: Transform.translate(
                  offset: Offset(0, -hide),
                  child: child,
                ),
              );
            },
            child: Material(
              color: cardBg,
              elevation: 0,
              child: SizedBox(
                height: headerHeight,
                child: Stack(
                  children: [
                    if (lifetimeOwned)
                      const Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Image(
                            image: AssetImage(
                              'assets/stickers/lifetime_lemonade.png',
                            ),
                            width: 34,
                            height: 34,
                            semanticLabel: 'Lifetime supporter',
                          ),
                        ),
                      ),
                    Center(
                      child: GestureDetector(
                        onTap: onTitleTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: AnimatedBuilder(
                            animation: titleAnimController,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: titleScale.value,
                                child: Text(
                                  'Lemonade',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: titleColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          tooltip: 'Feed view: ${viewMode.label}',
                          icon: const Icon(
                            MingCuteIcons.mgc_layout_line,
                            size: 24,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => showOptionPickerBottomSheet(
                            context: context,
                            title: 'Feed view',
                            options: FeedViewMode.values
                                .map((mode) => mode.label)
                                .toList(),
                            selected: viewMode.label,
                            onSelected: (label) => onViewModeSelected(
                              FeedViewMode.values.firstWhere(
                                (mode) => mode.label == label,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (topInset > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset,
            child: const ColoredBox(color: cardBg),
          ),
      ],
    );
  }
}

/// Title color for home feed type (Subscribed uses brand action).
Color homeTitleColorForType(String type) =>
    type == 'Subscribed' ? AppColors.action : const Color(0xFF000000);
