import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:bluerum/shared/widgets/markdown/bluerum_markdown.dart';

/// Design tokens for post-detail (matched to feed PostCard).
abstract final class PostDetailTokens {
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;

  static const double fontLabel = 10;
  static const double fontMeta = 12;
  static const double fontBody = 13;
  static const double fontTitle = 16;
  static const double fontCode = 12;

  static const double avatar = 20;
  static const double actionBarH = 32;
  static const double pillH = 32;
  static const double voteBtnW = 28;
  static const double pillPadH = 8;
  static const double iconMd = 16;

  /// Per-depth nest step — compact 13px tracks with short L-hooks.
  static const double threadIndent = 13;

  /// Thread gutter starts at the same X as shell pad.
  static const double threadGutter = spaceLg;

  static const Color border = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textBlack = Color(0xFF000000);
  static const Color actionIdle = Color(0xFF333333);
  static const Color fieldBg = Color(0xFFF5F6F8);

  static const List<Color> threadColors = [
    Color(0xFFCC9999),
    Color(0xFFCCBB99),
    Color(0xFFBBCC99),
    Color(0xFF99CC99),
    Color(0xFF99CCCC),
    Color(0xFF9999CC),
  ];

  static Color threadColorAt(int depthIndex) =>
      threadColors[depthIndex % threadColors.length];
}

/// Comment list rich body.
final MarkdownStyleSheet commentMarkdownStyle = MarkdownStyleSheet(
  p: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    color: PostDetailTokens.textPrimary,
    height: 1.35,
  ),
  a: BluerumMarkdownStyles.link(
    fontSize: PostDetailTokens.fontBody,
    height: 1.35,
  ),
  code: BluerumMarkdownStyles.code(
    fontSize: PostDetailTokens.fontCode,
    color: PostDetailTokens.textPrimary,
  ),
  codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
  blockquoteDecoration: const RoundedBorderDecoration(
    color: PostDetailTokens.border,
    width: 4,
    isHorizontal: false,
  ),
  blockquotePadding: const EdgeInsets.only(
    left: PostDetailTokens.spaceMd,
    top: PostDetailTokens.spaceXs,
    bottom: PostDetailTokens.spaceXs,
  ),
  listBullet: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    color: PostDetailTokens.textPrimary,
  ),
  strong: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    fontWeight: FontWeight.w700,
    color: PostDetailTokens.textPrimary,
    height: 1.35,
  ),
  em: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    fontStyle: FontStyle.italic,
    color: PostDetailTokens.textPrimary,
    height: 1.35,
  ),
);

final MarkdownStyleSheet postDetailMarkdownStyle = MarkdownStyleSheet(
  p: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    color: PostDetailTokens.textPrimary,
    height: 1.5,
  ),
  a: BluerumMarkdownStyles.link(fontSize: PostDetailTokens.fontBody),
  code: BluerumMarkdownStyles.code(
    fontSize: PostDetailTokens.fontCode,
    color: PostDetailTokens.textPrimary,
  ),
  codeblockDecoration: BluerumMarkdownStyles.codeblockDecoration,
  blockquoteDecoration: const RoundedBorderDecoration(
    color: PostDetailTokens.border,
    width: 4,
    isHorizontal: false,
  ),
  blockquotePadding: const EdgeInsets.only(
    left: PostDetailTokens.spaceMd,
    top: PostDetailTokens.spaceXs,
    bottom: PostDetailTokens.spaceXs,
  ),
  h1: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: PostDetailTokens.textBlack,
  ),
  h2: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: PostDetailTokens.textBlack,
  ),
  h3: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: PostDetailTokens.textBlack,
  ),
  listBullet: const TextStyle(
    fontSize: PostDetailTokens.fontBody,
    color: PostDetailTokens.textPrimary,
  ),
  horizontalRuleDecoration: const RoundedBorderDecoration(
    color: PostDetailTokens.border,
    width: 2,
    isHorizontal: true,
  ),
);

/// Hide platform scrollbars inside selectable markdown blocks.
class NoScrollbarBehavior extends ScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

String formatCompactCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  if (n == 0) return '';
  return n.toString();
}
