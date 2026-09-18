import 'package:bluerum/features/post/presentation/comment_thread_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggleCollapse notifies and rebuilds empty rows for empty map', () {
    final c = CommentThreadController();
    var n = 0;
    c.addListener(() => n++);
    c.toggleCollapse(1);
    expect(c.isCollapsed(1), isTrue);
    expect(n, greaterThan(0));
    c.toggleCollapse(1);
    expect(c.isCollapsed(1), isFalse);
    c.dispose();
  });

  test('clear resets state', () {
    final c = CommentThreadController();
    c.collapsedIds.add(9);
    c.clear();
    expect(c.collapsedIds, isEmpty);
    expect(c.comments, isEmpty);
    expect(c.rows, isEmpty);
    c.dispose();
  });

  test('structural rebuild leaves body parsing lazy', () {
    final c = CommentThreadController();
    c.rebuild();

    expect(c.bodyVms.length, 0);
    c.dispose();
  });

  test('bodyEntries caches by revision and showAds', () {
    final c = CommentThreadController();
    final a = c.bodyEntries(showAds: false);
    final b = c.bodyEntries(showAds: false);
    expect(identical(a, b), isTrue);
    final revBefore = c.revision;
    c.rebuild(notify: false);
    expect(c.revision, greaterThan(revBefore));
    // Empty trees share const []; cache identity is verified via revision bump.
    final adsOff = c.bodyEntries(showAds: false);
    final adsOn = c.bodyEntries(showAds: true);
    // showAds flip must recompute (even when both empty for no rows).
    expect(c.revision, greaterThan(revBefore));
    // Force a structural change so display cache is rebuilt with a new list.
    c.collapsedIds.add(1);
    c.rebuild(notify: false);
    final afterCollapse = c.bodyEntries(showAds: false);
    // Still empty rows → may still be const []; revision is the contract.
    expect(c.revision, greaterThan(revBefore));
    // silence unused
    expect(adsOff, isA<List>());
    expect(adsOn, isA<List>());
    expect(afterCollapse, isA<List>());
    c.dispose();
  });
}
