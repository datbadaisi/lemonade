import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bounce-on-tap vote control shared by feed cards and post detail.
class VoteBounceButton extends StatefulWidget {
  const VoteBounceButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.width,
    required this.height,
    required this.direction,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;
  final String? tooltip;

  /// 1 = up, -1 = down (affects launch direction).
  final int direction;

  @override
  State<VoteBounceButton> createState() => _VoteBounceButtonState();
}

class _VoteBounceButtonState extends State<VoteBounceButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _anim;
  double _randomAngle = 0;

  AnimationController get _controller {
    final existing = _ctrl;
    if (existing != null) return existing;
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 70,
      ),
    ]).animate(c);
    _ctrl = c;
    return c;
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _handleTap() {
    _randomAngle = (math.Random().nextDouble() - 0.5) * (math.pi / 9);
    _controller.forward(from: 0);
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: OverflowBox(
            alignment: Alignment.center,
            minWidth: widget.width + 48,
            maxWidth: widget.width + 48,
            minHeight: widget.height + 48,
            maxHeight: widget.height + 48,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(9999),
              child: InkResponse(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(9999),
                containedInkWell: false,
                radius: 30,
                splashFactory: InkRipple.splashFactory,
                splashColor: const Color(0xFF000000).withValues(alpha: 0.06),
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: _anim == null
                      ? widget.child
                      : AnimatedBuilder(
                          animation: _anim!,
                          builder: (_, child) {
                            final v = _anim!.value;
                            final dist = v * 100;
                            final dx = math.sin(_randomAngle) * dist;
                            final dy = -math.cos(_randomAngle) *
                                dist *
                                widget.direction;
                            return Transform.translate(
                              offset: Offset(dx, dy),
                              child: Transform.rotate(
                                angle: _randomAngle,
                                child: Transform.scale(
                                  scale: 1.0 + v * 0.12,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: widget.child,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
