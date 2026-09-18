import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:bluerum/features/post/presentation/comment_body_vm.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';

/// List-safe comment body by [CommentBodyVm.paintKind] — no post-fling swap.
class CommentBodyPaint extends StatefulWidget {
  const CommentBodyPaint({
    super.key,
    required this.vm,
    required this.styleSheet,
    this.onLinkTap,
    this.maxPlainLines = 12,
    this.fontSize = 13,
    this.height = 1.35,
    this.color = const Color(0xFF000000),
  });

  final CommentBodyVm vm;
  final MarkdownStyleSheet styleSheet;
  final ValueChanged<String?>? onLinkTap;
  final int maxPlainLines;
  final double fontSize;
  final double height;
  final Color color;

  @override
  State<CommentBodyPaint> createState() => _CommentBodyPaintState();
}

class _CommentBodyPaintState extends State<CommentBodyPaint> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CommentBodyPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm.contentKey != widget.vm.contentKey) {
      for (final r in _recognizers) {
        r.dispose();
      }
      _recognizers.clear();
    }
  }

  TextStyle get _base => TextStyle(
        fontSize: widget.fontSize,
        color: widget.color,
        height: widget.height,
      );

  TextStyle get _link => BluerumMarkdownStyles.link(
        fontSize: widget.fontSize,
        height: widget.height,
      );

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    switch (vm.paintKind) {
      case CommentBodyPaintKind.plain:
        final plain =
            vm.listPlain.isNotEmpty ? vm.listPlain : vm.markdownSource.trim();
        if (plain.isEmpty) return const SizedBox.shrink();
        return Text(
          plain,
          maxLines: widget.maxPlainLines,
          overflow: TextOverflow.ellipsis,
          style: _base,
        );

      case CommentBodyPaintKind.linksOnly:
        if (vm.linkSegments.isEmpty) {
          final plain = vm.listPlain;
          if (plain.isEmpty) return const SizedBox.shrink();
          return Text(
            plain,
            maxLines: widget.maxPlainLines,
            overflow: TextOverflow.ellipsis,
            style: _base,
          );
        }
        // Rebuild recognizers only when empty (new content already cleared).
        if (_recognizers.isEmpty) {
          for (final seg in vm.linkSegments) {
            if (!seg.isLink) continue;
            final href = seg.href!;
            _recognizers.add(
              TapGestureRecognizer()
                ..onTap = () => widget.onLinkTap?.call(href),
            );
          }
        }
        var linkI = 0;
        final spans = <TextSpan>[];
        for (final seg in vm.linkSegments) {
          if (seg.isLink) {
            final r = _recognizers[linkI++];
            spans.add(
              TextSpan(
                text: seg.text,
                style: _link,
                recognizer: r,
              ),
            );
          } else {
            spans.add(TextSpan(text: seg.text, style: _base));
          }
        }
        return Text.rich(
          TextSpan(style: _base, children: spans),
          maxLines: widget.maxPlainLines,
          overflow: TextOverflow.ellipsis,
        );

      case CommentBodyPaintKind.fullRich:
        final rich = vm.markdownSource.trim();
        if (rich.isEmpty) return const SizedBox.shrink();
        return BluerumMarkdown(
          data: rich,
          softLineBreak: true,
          selectable: false,
          styleSheet: widget.styleSheet,
          onTapLink: (_, href, _) => widget.onLinkTap?.call(href),
        );
    }
  }
}
