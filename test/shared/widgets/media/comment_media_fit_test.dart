import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/shared/widgets/media/media_fit.dart';

void main() {
  group('fitCommentMediaSize', () {
    test('landscape uses full width', () {
      final s = fitCommentMediaSize(aspect: 16 / 9, maxW: 360, maxH: 400);
      expect(s.width, closeTo(360, 0.1));
      expect(s.height, closeTo(360 * 9 / 16, 0.5));
    });

    test('portrait shrinks width to fit max height (full image, no crop)', () {
      // 9:16 tall image in a 360×400 box → height hits 400, width < 360
      final s = fitCommentMediaSize(aspect: 9 / 16, maxW: 360, maxH: 400);
      expect(s.height, closeTo(400, 0.1));
      expect(s.width, closeTo(400 * 9 / 16, 0.5));
      expect(s.width, lessThan(360));
    });

    test('square fills the smaller side of the box', () {
      final s = fitCommentMediaSize(aspect: 1, maxW: 300, maxH: 500);
      expect(s.width, closeTo(300, 0.1));
      expect(s.height, closeTo(300, 0.1));
    });

    test('ultra-wide stays within max height', () {
      final s = fitCommentMediaSize(aspect: 4, maxW: 360, maxH: 80);
      expect(s.height, closeTo(80, 0.1));
      expect(s.width, closeTo(320, 0.5)); // 80 * 4
    });
  });
}
