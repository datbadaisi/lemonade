import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:ming_cute_icons/ming_cute_icons.dart';

import 'package:bluerum/app/theme/app_colors.dart';
import 'package:bluerum/core/utils/markdown_utils.dart';

/// Shared markdown / rich-text link style: accent color only, no underline.
abstract final class BluerumMarkdownStyles {
  static TextStyle link({double? fontSize, double? height}) => TextStyle(
        fontSize: fontSize,
        height: height,
        color: AppColors.action,
        decoration: TextDecoration.none,
      );

  /// Inline / fenced code: same body weight, no gray chip / background.
  static TextStyle code({
    double? fontSize,
    Color color = const Color(0xFF000000),
    double? height,
  }) =>
      TextStyle(
        fontSize: fontSize,
        color: color,
        height: height,
      );

  /// Fenced code block chrome — none (no gray rounded panel).
  static const BoxDecoration codeblockDecoration = BoxDecoration();
}

/// Drops the gray rounded "chip" on inline `code` and the gray panel on
/// fenced blocks. Callers may still pass these; [BluerumMarkdown] strips them.
MarkdownStyleSheet sanitizeMarkdownStyleSheet(MarkdownStyleSheet sheet) {
  final rawCode = sheet.code;
  final code = rawCode == null
      ? null
      : TextStyle(
          color: rawCode.color,
          fontSize: rawCode.fontSize,
          fontWeight: rawCode.fontWeight,
          fontStyle: rawCode.fontStyle,
          fontFamily: rawCode.fontFamily,
          fontFamilyFallback: rawCode.fontFamilyFallback,
          height: rawCode.height,
          letterSpacing: rawCode.letterSpacing,
          wordSpacing: rawCode.wordSpacing,
          // Intentionally omit backgroundColor / background — those paint the
          // gray rounded highlight on backticks (`kill`, `pkill`, …).
        );

  return sheet.copyWith(
    code: code,
    codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
    codeblockPadding: EdgeInsets.zero,
  );
}

/// Renders fenced `pre` content with soft-wrap instead of a horizontal
/// scrollbar (flutter_markdown_plus default).
class _WrappingPreBuilder extends MarkdownElementBuilder {
  _WrappingPreBuilder(this.codeStyle, {required this.selectable});

  final TextStyle? codeStyle;
  final bool selectable;

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    // Match flutter_markdown_plus formatText: drop trailing fence newline.
    final content = text.text.replaceAll(RegExp(r'\n$'), '');
    final span = TextSpan(style: codeStyle, text: content);
    if (selectable) {
      return SelectableText.rich(span);
    }
    // softWrap defaults true — long lines wrap; no Axis.horizontal scroll.
    return Text.rich(span);
  }
}

class BluerumMarkdown extends StatelessWidget {
  final String data;
  final MarkdownStyleSheet? styleSheet;
  final void Function(String?, String?, String?)? onTapLink;
  final bool selectable;
  final MarkdownImageBuilder? imageBuilder;
  final bool softLineBreak;

  const BluerumMarkdown({
    super.key,
    required this.data,
    this.styleSheet,
    this.onTapLink,
    this.selectable = false,
    this.imageBuilder,
    this.softLineBreak = false,
  });

  MarkdownStyleSheet _resolvedStyle(BuildContext context) {
    final base =
        styleSheet ?? MarkdownStyleSheet.fromTheme(Theme.of(context));
    return sanitizeMarkdownStyleSheet(base);
  }

  Map<String, MarkdownElementBuilder> _builders(MarkdownStyleSheet sheet) => {
        'pre': _WrappingPreBuilder(sheet.code, selectable: selectable),
      };

  Widget _markdownBody(BuildContext context, String source) {
    final sheet = _resolvedStyle(context);
    return MarkdownBody(
      data: source,
      styleSheet: sheet,
      builders: _builders(sheet),
      onTapLink: onTapLink,
      selectable: selectable,
      imageBuilder: imageBuilder,
      softLineBreak: softLineBreak,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lemmy-style spoiler fences → interactive expand/collapse (not raw :::).
    final matches = kLemmySpoilerBlockRegex.allMatches(data).toList();

    if (matches.isEmpty) {
      return _markdownBody(context, data);
    }

    final children = <Widget>[];
    int lastIndex = 0;

    for (final match in matches) {
      // Add text block before the spoiler block
      if (match.start > lastIndex) {
        final text = data.substring(lastIndex, match.start).trim();
        if (text.isNotEmpty) {
          children.add(_markdownBody(context, text));
        }
      }

      // Add interactive spoiler block
      final title = match.group(1)?.trim() ?? 'Spoiler';
      final content = match.group(2) ?? '';
      children.add(_SpoilerWidget(
        title: title.isEmpty ? 'Spoiler' : title,
        content: content,
        styleSheet: styleSheet,
        onTapLink: onTapLink,
        selectable: selectable,
        imageBuilder: imageBuilder,
        softLineBreak: softLineBreak,
      ));

      lastIndex = match.end;
    }

    // Add any remaining text block
    if (lastIndex < data.length) {
      final text = data.substring(lastIndex).trim();
      if (text.isNotEmpty) {
        children.add(_markdownBody(context, text));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _SpoilerWidget extends StatefulWidget {
  final String title;
  final String content;
  final MarkdownStyleSheet? styleSheet;
  final void Function(String?, String?, String?)? onTapLink;
  final bool selectable;
  final MarkdownImageBuilder? imageBuilder;
  final bool softLineBreak;

  const _SpoilerWidget({
    required this.title,
    required this.content,
    this.styleSheet,
    this.onTapLink,
    this.selectable = false,
    this.imageBuilder,
    required this.softLineBreak,
  });

  @override
  State<_SpoilerWidget> createState() => _SpoilerWidgetState();
}

class _SpoilerWidgetState extends State<_SpoilerWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.styleSheet?.p?.color ?? const Color(0xFF000000);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _expanded
                      ? MingCuteIcons.mgc_down_line
                      : MingCuteIcons.mgc_right_line,
                  size: 20,
                  color: accentColor.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 8),
                  child: BluerumMarkdown(
                    data: widget.content,
                    styleSheet: widget.styleSheet,
                    onTapLink: widget.onTapLink,
                    selectable: widget.selectable,
                    imageBuilder: widget.imageBuilder,
                    softLineBreak: widget.softLineBreak,
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

class RoundedBorderDecoration extends Decoration {
  final Color color;
  final double width;
  final bool isHorizontal;

  const RoundedBorderDecoration({
    required this.color,
    required this.width,
    required this.isHorizontal,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _RoundedBorderPainter(this);
  }
}

class _RoundedBorderPainter extends BoxPainter {
  final RoundedBorderDecoration decoration;

  _RoundedBorderPainter(this.decoration);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;

    if (decoration.isHorizontal) {
      final size = configuration.size ?? Size.zero;
      final y = offset.dy + size.height / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx,
          y - decoration.width / 2,
          size.width,
          decoration.width,
        ),
        Radius.circular(decoration.width / 2),
      );
      canvas.drawRRect(rect, paint);
    } else {
      final size = configuration.size ?? Size.zero;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          decoration.width,
          size.height,
        ),
        Radius.circular(decoration.width / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }
}
