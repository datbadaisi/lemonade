import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/shared/widgets/markdown/markdown_link_text_controller.dart';

void main() {
  group('MarkdownLinkTextController', () {
    late MarkdownLinkTextController ctrl;

    setUp(() {
      ctrl = MarkdownLinkTextController();
    });

    tearDown(() {
      ctrl.dispose();
    });

    test('insertOrReplaceLink with no selection inserts label + link', () {
      ctrl.text = 'Hello ';
      ctrl.selection = const TextSelection.collapsed(offset: 6);

      ctrl.insertOrReplaceLink(
        rangeStart: 6,
        rangeEnd: 6,
        displayText: 'world',
        url: 'https://example.com',
      );

      expect(ctrl.text, 'Hello world');
      expect(ctrl.rawText, 'Hello [world](https://example.com)');
      expect(ctrl.links, hasLength(1));
      expect(ctrl.links.first.start, 6);
      expect(ctrl.links.first.end, 11);
      expect(ctrl.links.first.url, 'https://example.com');
    });

    test('insertOrReplaceLink with selection wraps selected text', () {
      ctrl.text = 'Click here please';
      ctrl.insertOrReplaceLink(
        rangeStart: 6,
        rangeEnd: 10, // "here"
        displayText: 'here',
        url: 'https://example.com',
      );

      expect(ctrl.text, 'Click here please');
      expect(ctrl.rawText, 'Click [here](https://example.com) please');
    });

    test('insertOrReplaceLink can change display text of selection', () {
      ctrl.text = 'Click here please';
      ctrl.insertOrReplaceLink(
        rangeStart: 6,
        rangeEnd: 10,
        displayText: 'this',
        url: 'https://example.com',
      );

      expect(ctrl.text, 'Click this please');
      expect(ctrl.rawText, 'Click [this](https://example.com) please');
    });

    test('setRawText parses links and leaves images intact', () {
      ctrl.setRawText(
        'See [docs](https://docs.example.com) and ![img](https://img.example.com/a.png)',
      );

      expect(ctrl.text,
          'See docs and ![img](https://img.example.com/a.png)');
      expect(ctrl.rawText,
          'See [docs](https://docs.example.com) and ![img](https://img.example.com/a.png)');
      expect(ctrl.links, hasLength(1));
      expect(ctrl.links.first.url, 'https://docs.example.com');
    });

    test('rawText round-trips after draft-style save/load', () {
      ctrl.text = 'A and B';
      ctrl.insertOrReplaceLink(
        rangeStart: 0,
        rangeEnd: 1,
        displayText: 'A',
        url: 'https://a.test',
      );
      ctrl.insertOrReplaceLink(
        rangeStart: 6,
        rangeEnd: 7,
        displayText: 'B',
        url: 'https://b.test',
      );

      final saved = ctrl.rawText;
      expect(saved, '[A](https://a.test) and [B](https://b.test)');

      final restored = MarkdownLinkTextController();
      addTearDown(restored.dispose);
      restored.setRawText(saved);

      expect(restored.text, 'A and B');
      expect(restored.rawText, saved);
      expect(restored.links, hasLength(2));
    });

    test('editing inside linked text keeps the link range', () {
      ctrl.text = 'link';
      ctrl.addLink(0, 4, 'https://example.com');
      // Insert 'ed' after 'link' → still inside link adjustment (at end is outside)
      // Type in the middle: "li|nk" → "liXnk"
      ctrl.selection = const TextSelection.collapsed(offset: 2);
      ctrl.value = const TextEditingValue(
        text: 'liXnk',
        selection: TextSelection.collapsed(offset: 3),
      );

      expect(ctrl.text, 'liXnk');
      expect(ctrl.links, hasLength(1));
      expect(ctrl.links.first.start, 0);
      expect(ctrl.links.first.end, 5);
      expect(ctrl.rawText, '[liXnk](https://example.com)');
    });

    test('normalizeMarkdownUrl adds https when missing', () {
      expect(normalizeMarkdownUrl('example.com'), 'https://example.com');
      expect(normalizeMarkdownUrl('https://a.com'), 'https://a.com');
      expect(normalizeMarkdownUrl('http://a.com'), 'http://a.com');
    });

    test('captureLinkInsertContext captures selection before unfocus', () {
      ctrl.text = 'hello world';
      ctrl.selection = const TextSelection(baseOffset: 0, extentOffset: 5);

      final ctx = captureLinkInsertContext(ctrl);
      expect(ctx.hasSelection, isTrue);
      expect(ctx.rangeStart, 0);
      expect(ctx.rangeEnd, 5);
      expect(ctx.initialDisplayText, 'hello');
      expect(ctx.initialUrl, isEmpty);
    });

    test('captureLinkInsertContext edits existing link under cursor', () {
      ctrl.text = 'hello world';
      ctrl.addLink(0, 5, 'https://hello.test');
      ctrl.selection = const TextSelection.collapsed(offset: 2);

      final ctx = captureLinkInsertContext(ctrl);
      expect(ctx.isEditingLink, isTrue);
      expect(ctx.rangeStart, 0);
      expect(ctx.rangeEnd, 5);
      expect(ctx.initialDisplayText, 'hello');
      expect(ctx.initialUrl, 'https://hello.test');
    });
  });
}
