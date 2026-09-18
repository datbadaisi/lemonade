import 'package:flutter/material.dart';
import 'package:bluerum/features/post/presentation/post_detail_theme.dart';
import 'package:bluerum/shared/models/comment.dart';

/// Compact role / status pill on detail author rows (true stadium shape).
class DetailRoleBadge extends StatelessWidget {
  const DetailRoleBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: PostDetailTokens.fontLabel,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Thread gutter / connector lines for nested comments.
class ThreadLinePainter extends CustomPainter {
  /// Junction Y ≈ author pad-top (8) + half avatar (10).
  static const double connectorY = 18;

  /// Classic geometry: short hook inside the 13px indent track.
  static const double cornerR = 5;
  static const double defaultStrokeWidth = 2.2;

  /// Sit on the left edge of the indent track.
  static const double lineX = 1.0;

  const ThreadLinePainter({
    required this.color,
    required this.continues,
    required this.isConnector,
    this.progress = 1.0,
    this.strokeWidth = defaultStrokeWidth,
  });

  final Color color;
  final bool continues;
  final bool isConnector;

  /// 0.0 → 1.0 animation progress (entrance). Defaults to full.
  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final clipEnd = size.height * progress;

    if (isConnector) {
      final cy = connectorY.clamp(0.0, size.height);
      final r = cornerR.clamp(0.0, cy).clamp(0.0, size.width - lineX);
      final connectorVisible = clipEnd >= cy - r;

      if (continues) {
        canvas.drawLine(Offset(lineX, 0), Offset(lineX, clipEnd), paint);
      } else if (!connectorVisible) {
        canvas.drawLine(Offset(lineX, 0), Offset(lineX, clipEnd), paint);
      }

      if (connectorVisible) {
        const stub = 3.0;
        final armEnd = (lineX + r + stub).clamp(0.0, size.width);
        final path = Path()
          ..moveTo(lineX, continues ? cy - r : 0)
          ..lineTo(lineX, cy - r)
          ..quadraticBezierTo(lineX, cy, lineX + r, cy)
          ..lineTo(armEnd, cy);
        canvas.drawPath(path, paint);
      }
    } else if (continues) {
      canvas.drawLine(Offset(lineX, 0), Offset(lineX, clipEnd), paint);
    }
  }

  @override
  bool shouldRepaint(ThreadLinePainter old) =>
      old.color != color ||
      old.continues != continues ||
      old.isConnector != isConnector ||
      old.progress != progress ||
      old.strokeWidth != strokeWidth;
}

/// Horizontal right-drag reveals the parent comment; connector thickens while
/// dragging then springs back.
class SwipeableCommentRow extends StatefulWidget {
  const SwipeableCommentRow({
    super.key,
    required this.child,
    required this.commentView,
    this.onRevealParent,
    required this.threadColor,
    required this.threadContinues,
    required this.connectorLeft,
  });

  final Widget child;
  final CommentView commentView;
  final VoidCallback? onRevealParent;
  final Color threadColor;
  final bool threadContinues;

  /// Left offset for the connector line (= gutter + ancestors * indent).
  final double connectorLeft;

  @override
  State<SwipeableCommentRow> createState() => _SwipeableCommentRowState();
}

class _SwipeableCommentRowState extends State<SwipeableCommentRow>
    with SingleTickerProviderStateMixin {
  static const double _kThreshold = 80.0;
  static const double _kMaxStrokeGrowth = 3.4;
  static const Duration _kSnapBackDuration = Duration(milliseconds: 320);

  double _dragOffset = 0.0;
  AnimationController? _snapCtrl;
  int _snapEpoch = 0;

  @override
  void dispose() {
    _cancelSnap();
    super.dispose();
  }

  void _cancelSnap() {
    _snapEpoch++;
    final ctrl = _snapCtrl;
    _snapCtrl = null;
    if (ctrl == null) return;
    ctrl.stop();
    ctrl.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _cancelSnap();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final next = (_dragOffset + details.delta.dx).clamp(0.0, 150.0);
    if ((next - _dragOffset).abs() < 0.5) return;
    setState(() => _dragOffset = next);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset >= _kThreshold && widget.onRevealParent != null) {
      widget.onRevealParent!();
    }
    _animateSnapBack();
  }

  void _onHorizontalDragCancel() {
    _animateSnapBack();
  }

  void _animateSnapBack() {
    if (!mounted || _dragOffset == 0) return;
    _cancelSnap();
    final from = _dragOffset;
    final epoch = _snapEpoch;
    final ctrl = AnimationController(vsync: this, duration: _kSnapBackDuration);
    void tick() {
      if (!mounted || epoch != _snapEpoch) return;
      final t = Curves.easeOutCubic.transform(ctrl.value);
      setState(() => _dragOffset = from * (1.0 - t));
    }

    ctrl.addListener(tick);
    _snapCtrl = ctrl;
    ctrl.forward().whenCompleteOrCancel(() {
      ctrl.removeListener(tick);
      if (epoch != _snapEpoch || !identical(_snapCtrl, ctrl)) return;
      if (mounted) {
        setState(() => _dragOffset = 0);
      } else {
        _dragOffset = 0;
      }
      _snapCtrl = null;
      ctrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final intensity = (_dragOffset / _kThreshold).clamp(0.0, 1.0);
    final sw =
        ThreadLinePainter.defaultStrokeWidth + _kMaxStrokeGrowth * intensity;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: widget.connectorLeft,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: SizedBox(
              width: PostDetailTokens.threadIndent,
              child: CustomPaint(
                painter: ThreadLinePainter(
                  color: widget.threadColor,
                  continues: widget.threadContinues,
                  isConnector: true,
                  progress: 1.0,
                  strokeWidth: sw,
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_dragOffset, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onHorizontalDragCancel: _onHorizontalDragCancel,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
