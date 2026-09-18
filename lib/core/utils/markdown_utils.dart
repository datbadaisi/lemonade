import 'package:markdown/markdown.dart' as md;

/// Extracts image URLs from all `![](url)` patterns in a Markdown body.
/// Returns a list of unique URLs in order of appearance.
List<String> extractMarkdownImageUrls(String source) {
  final seen = <String>{};
  final urls = <String>[];
  final regex = RegExp(r'!\[.*?\]\((https?://[^\s)]+)\)');
  for (final match in regex.allMatches(source)) {
    final url = match.group(1)!;
    if (seen.add(url)) {
      urls.add(url);
    }
  }
  return urls;
}

/// Strips all `![](...)` image syntax from a Markdown body, returning
/// plain markdown text without image elements.
String stripMarkdownImages(String source) {
  return source.replaceAll(RegExp(r'!\[.*?\]\(https?://[^\s)]+\)'), '');
}

/// Collapsed spoiler marker emitted by [markdownToPlainText].
///
/// Not meant to be shown as a glyph in the UI — replace with
/// `MingCuteIcons.mgc_right_line` (same as interactive spoilers in
/// post detail) when rendering feed / list previews.
const String kSpoilerCollapsedMarker = '\u25B6'; // ▶

/// Lemmy spoiler fence: `::: spoiler Title\n…\n:::`.
///
/// Tolerant of casing, CRLF, trailing spaces on the title line, and a missing
/// final newline before the closing `:::`. Shared by plain-text collapse and
/// interactive [BluerumMarkdown] spoilers.
final RegExp kLemmySpoilerBlockRegex = RegExp(
  r':::[ \t]*spoiler[ \t]*([^\r\n]*)\r?\n([\s\S]*?)(?:\r?\n)?[ \t]*:::',
  caseSensitive: false,
);

/// Parses Markdown via the full AST and extracts only the text content,
/// matching Reddit's feed preview behavior exactly.
///
/// - Strips all formatting syntax (bold, italic, headers, etc.)
/// - Links → link text only (`[text](url)` → `text`)
/// - Images → removed entirely
/// - Code blocks → removed entirely
/// - Auto-links → kept as-is (`<https://...>` → `https://...`)
/// - HTML entities → decoded naturally by the parser
/// - Nested formatting → resolved correctly (AST-based, not regex)
/// - Multiple whitespace → collapsed to single space
/// - Spoiler blocks → [kSpoilerCollapsedMarker] + title (render as icon in UI)
String markdownToPlainText(String source) {
  // Replace Lemmy-style spoiler blocks with a collapsed indicator marker + title.
  final cleanSource = source.replaceAllMapped(kLemmySpoilerBlockRegex, (match) {
    final title = match.group(1)?.trim() ?? '';
    final displayTitle = title.isEmpty ? 'Spoiler' : title;
    return '$kSpoilerCollapsedMarker $displayTitle';
  });

  final document = md.Document().parse(cleanSource);
  final buffer = StringBuffer();
  _extractText(document, buffer);
  final result = buffer.toString();

  // Collapse whitespace: multiple spaces → one, multiple newlines → newline
  return result
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

void _extractText(List<md.Node> nodes, StringBuffer buffer) {
  for (final node in nodes) {
    if (node is md.Text) {
      buffer.write(node.text);
    } else if (node is md.Element) {
      // ── Elements that contribute no text ──
      if (node.tag == 'img') continue; // images → nothing

      // ── Line break / paragraph spacing ──
      if (node.tag == 'br' || node.tag == 'p' || node.tag == 'li') {
        buffer.write('\n');
      }
      if (node.tag == 'blockquote') {
        buffer.write('\n');
      }

      // ── Headers: h1–h6 add a newline after text ──
      if (node.tag.startsWith('h') &&
          node.tag.length == 2 &&
          int.tryParse(node.tag[1]) != null) {
        _extractText(node.children ?? [], buffer);
        buffer.write('\n');
        continue;
      }

      // ── Recurse into children ──
      _extractText(node.children ?? [], buffer);
    }
    // md.HorizontalRule — nothing
  }
}
