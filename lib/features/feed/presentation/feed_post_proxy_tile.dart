import 'package:flutter/material.dart';

import 'package:bluerum/features/feed/presentation/post_card_vm.dart';

/// Content-complete, network-free card shell (tests / optional surfaces).
///
/// Home feed no longer swaps to this during scroll — that blanked body/meta and
/// flashed black→gray media. Kept for height helpers and future reuse.
class FeedPostProxyTile extends StatelessWidget {
  const FeedPostProxyTile({
    super.key,
    required this.vm,
    required this.height,
    this.onTap,
  });

  final PostCardVm vm;

  /// Preferred outer height (measured or estimate); used as [minHeight] only.
  final double height;
  final VoidCallback? onTap;

  static const Color _bg = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF000000);
  static const Color _textSecondary = Color(0xFF525252);
  static const Color _placeholder = Color(0xFFE8E8E8);
  static const Color _border = Color(0xFFE0E0E0);

  static const double _padX = 16;
  static const double _padY = 12;
  static const double _gap = 8;
  static const double _avatar = 20;
  static const double _actionH = 32;

  @override
  Widget build(BuildContext context) {
    final minH = height.isFinite && height > 0 ? height : vm.estimatedHeight;

    final body = ColoredBox(
      color: _bg,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minH),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _padX,
            vertical: _padY,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _avatar,
                child: Row(
                  children: [
                    Container(
                      width: _avatar,
                      height: _avatar,
                      decoration: const BoxDecoration(
                        color: _placeholder,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initial(
                          vm.communityTitle.isNotEmpty
                              ? vm.communityTitle
                              : vm.communityName,
                        ),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'c/${vm.communityName} · u/${vm.creatorName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _gap),
              Text(
                vm.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.3,
                ),
              ),
              if (vm.bodyPreview.isNotEmpty) ...[
                const SizedBox(height: _gap),
                Text(
                  vm.bodyPreview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
              if (vm.hasMedia) ...[
                const SizedBox(height: _gap),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: vm.aspectRatio,
                    child: const ColoredBox(color: _placeholder),
                  ),
                ),
              ],
              const SizedBox(height: _gap),
              SizedBox(
                height: _actionH,
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: _actionH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: _border),
                      ),
                    ),
                    const SizedBox(width: _gap),
                    Container(
                      width: 96,
                      height: _actionH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: _border),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return body;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: body,
    );
  }

  static String _initial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCode(t.runes.first).toUpperCase();
  }
}
