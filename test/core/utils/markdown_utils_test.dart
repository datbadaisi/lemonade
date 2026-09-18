import 'package:bluerum/core/utils/markdown_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('markdownToPlainText', () {
    test('converts basic formatting to plain text', () {
      final input = '# Header\nThis is **bold** and *italic* text.';
      final expected = 'Header\n\nThis is bold and italic text.';
      expect(markdownToPlainText(input), expected);
    });

    test('strips markdown images', () {
      final input = 'Here is an image: ![alt text](https://example.com/image.png) and text.';
      final expected = 'Here is an image: and text.';
      expect(markdownToPlainText(input), expected);
    });

    test('resolves links to link text only', () {
      final input = 'Visit [Google](https://google.com) for searching.';
      final expected = 'Visit Google for searching.';
      expect(markdownToPlainText(input), expected);
    });

    test('replaces Lemmy-style spoiler blocks with collapsed indicator', () {
      final input = '''
Before spoiler.

::: spoiler Secret Title
Snape kills Dumbledore
:::

After spoiler.
''';
      final expected =
          'Before spoiler.\n$kSpoilerCollapsedMarker Secret Title\nAfter spoiler.';
      expect(markdownToPlainText(input), expected);
    });

    test('replaces multiple spoiler blocks', () {
      final input = '''
Start.
::: spoiler First
Snape kills Dumbledore
:::
Middle.
::: spoiler Second
Another secret
:::
End.
''';
      final expected =
          'Start.\n$kSpoilerCollapsedMarker First\nMiddle.\n$kSpoilerCollapsedMarker Second\nEnd.';
      expect(markdownToPlainText(input), expected);
    });

    test('handles empty spoiler or different whitespace formatting', () {
      final input = 'Test :::spoiler   \nsecret content\n::: test';
      final expected = 'Test $kSpoilerCollapsedMarker Spoiler test';
      expect(markdownToPlainText(input), expected);
    });

    test('handles SPOILER casing and missing newline before close', () {
      final input = '::: SPOILER Title\nsecret:::';
      final expected = '$kSpoilerCollapsedMarker Title';
      expect(markdownToPlainText(input), expected);
    });

    test('kLemmySpoilerBlockRegex matches standard fence', () {
      const body = '::: spoiler Hi\nsecret\n:::';
      expect(kLemmySpoilerBlockRegex.hasMatch(body), isTrue);
      final m = kLemmySpoilerBlockRegex.firstMatch(body)!;
      expect(m.group(1)?.trim(), 'Hi');
      expect(m.group(2)?.trim(), 'secret');
    });
  });
}
