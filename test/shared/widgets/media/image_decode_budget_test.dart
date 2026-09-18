import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/shared/widgets/media/media_budget.dart';
import 'package:bluerum/shared/widgets/media/media_precache.dart';

void main() {
  setUp(() {
    ImageDecodeBudget.debugRestoreDefaults();
    ImagePaintBudget.debugResetForTest();
  });

  tearDown(() {
    ImageDecodeBudget.debugRestoreDefaults();
    ImagePaintBudget.debugResetForTest();
  });

  group('ImageDecodeBudget', () {
    test('schedules one job at a time and pumps queue', () async {
      final order = <int>[];
      final firstDone = Completer<void Function()>();

      ImageDecodeBudget.schedule((done) {
        order.add(1);
        firstDone.complete(done);
      });
      ImageDecodeBudget.schedule((done) {
        order.add(2);
        done();
      });

      expect(ImageDecodeBudget.inFlightCount, 1);
      expect(ImageDecodeBudget.queueLength, 1);
      expect(order, [1]);

      final done1 = await firstDone.future;
      done1();
      expect(order, [1, 2]);
      expect(ImageDecodeBudget.pendingCount, 0);
    });

    test('clearPending drops queue but keeps in-flight', () async {
      final held = Completer<void Function()>();
      var secondRan = false;

      ImageDecodeBudget.schedule((done) {
        held.complete(done);
      });
      ImageDecodeBudget.schedule((done) {
        secondRan = true;
        done();
      });

      expect(ImageDecodeBudget.queueLength, 1);
      ImageDecodeBudget.clearPending(notify: false);
      expect(ImageDecodeBudget.queueLength, 0);
      expect(ImageDecodeBudget.inFlightCount, 1);
      expect(secondRan, isFalse);

      (await held.future)();
      expect(ImageDecodeBudget.inFlightCount, 0);
      expect(secondRan, isFalse);
    });

    test('reset abandons in-flight and frees the slot', () async {
      final held = Completer<void Function()>();
      var secondRan = false;

      ImageDecodeBudget.schedule((done) {
        held.complete(done);
      });
      expect(ImageDecodeBudget.inFlightCount, 1);

      ImageDecodeBudget.reset(notify: false);
      expect(ImageDecodeBudget.inFlightCount, 0);
      expect(ImageDecodeBudget.queueLength, 0);

      (await held.future)();
      expect(ImageDecodeBudget.inFlightCount, 0);

      ImageDecodeBudget.schedule((done) {
        secondRan = true;
        done();
      });
      expect(secondRan, isTrue);
      expect(ImageDecodeBudget.pendingCount, 0);
    });

    test('watchdog frees slot when done is never called', () {
      fakeAsync((async) {
        ImageDecodeBudget.debugJobTimeout = const Duration(milliseconds: 50);

        ImageDecodeBudget.schedule((done) {
          // Intentionally never call done.
        });
        expect(ImageDecodeBudget.inFlightCount, 1);

        async.elapse(const Duration(milliseconds: 49));
        expect(ImageDecodeBudget.inFlightCount, 1);

        async.elapse(const Duration(milliseconds: 2));
        expect(ImageDecodeBudget.inFlightCount, 0);

        var ran = false;
        ImageDecodeBudget.schedule((done) {
          ran = true;
          done();
        });
        expect(ran, isTrue);
      });
    });

    test('done is idempotent after watchdog', () {
      fakeAsync((async) {
        ImageDecodeBudget.debugJobTimeout = const Duration(milliseconds: 20);
        void Function()? captured;

        ImageDecodeBudget.schedule((done) {
          captured = done;
        });
        async.elapse(const Duration(milliseconds: 25));
        expect(ImageDecodeBudget.inFlightCount, 0);

        // Late done from abandoned work must not go negative / break pump.
        captured!();
        expect(ImageDecodeBudget.inFlightCount, 0);
      });
    });

    test('reset bumps MediaBudgetEpoch when notify is true', () {
      final before = MediaBudgetEpoch.listenable.value;
      ImageDecodeBudget.reset(notify: true);
      expect(MediaBudgetEpoch.listenable.value, before + 1);
    });

    test('done is idempotent', () {
      void Function()? captured;
      ImageDecodeBudget.schedule((done) {
        captured = done;
      });
      expect(ImageDecodeBudget.inFlightCount, 1);
      captured!();
      captured!();
      expect(ImageDecodeBudget.inFlightCount, 0);
    });

    test('jobTimeout defaults to mediaPrecacheTimeout', () {
      expect(ImageDecodeBudget.jobTimeout, mediaPrecacheTimeout);
    });
  });

  group('recoverMediaBudgets', () {
    test('abandons in-flight and bumps epoch when notify is true', () {
      ImageDecodeBudget.schedule((done) {});
      expect(ImageDecodeBudget.inFlightCount, 1);

      final before = MediaBudgetEpoch.listenable.value;
      recoverMediaBudgets();
      expect(ImageDecodeBudget.inFlightCount, 0);
      expect(ImageDecodeBudget.queueLength, 0);
      expect(ImagePaintBudget.queueLength, 0);
      expect(MediaBudgetEpoch.listenable.value, before + 1);
    });

    test('pending-only does not abandon in-flight', () {
      final held = Completer<void Function()>();
      ImageDecodeBudget.schedule((done) {
        held.complete(done);
      });
      ImageDecodeBudget.schedule((done) {
        done();
      });
      expect(ImageDecodeBudget.inFlightCount, 1);
      expect(ImageDecodeBudget.queueLength, 1);

      recoverMediaBudgets(notify: false, abandonInFlight: false);
      expect(ImageDecodeBudget.inFlightCount, 1);
      expect(ImageDecodeBudget.queueLength, 0);

      // ignore: discarded_futures
      held.future.then((done) => done());
    });

    test('notify false does not bump epoch', () {
      final before = MediaBudgetEpoch.listenable.value;
      recoverMediaBudgets(notify: false);
      expect(MediaBudgetEpoch.listenable.value, before);
    });

    test('softRecoverMediaBudgets defers epoch bump', () async {
      ImageDecodeBudget.schedule((done) {});
      expect(ImageDecodeBudget.inFlightCount, 1);

      final before = MediaBudgetEpoch.listenable.value;
      MediaBudgetEpoch.cancelDeferredBump();
      softRecoverMediaBudgets(reArmFeedWhenIdle: true);
      expect(ImageDecodeBudget.inFlightCount, 0);
      expect(MediaBudgetEpoch.listenable.value, before);

      await Future<void>.delayed(
        mediaRouteTransitionQuiet + const Duration(milliseconds: 50),
      );
      expect(MediaBudgetEpoch.listenable.value, before + 1);
    });

    test('cancelDeferredBump prevents soft re-arm', () async {
      final before = MediaBudgetEpoch.listenable.value;
      MediaBudgetEpoch.cancelDeferredBump();
      softRecoverMediaBudgets(reArmFeedWhenIdle: true);
      MediaBudgetEpoch.cancelDeferredBump();
      await Future<void>.delayed(
        mediaRouteTransitionQuiet + const Duration(milliseconds: 50),
      );
      expect(MediaBudgetEpoch.listenable.value, before);
    });
  });

  group('runWithMediaBudgetRecovery', () {
    test('recovers, runs work, then bumps when mounted', () async {
      ImageDecodeBudget.schedule((done) {});
      expect(ImageDecodeBudget.inFlightCount, 1);
      final before = MediaBudgetEpoch.listenable.value;
      var ran = false;

      await runWithMediaBudgetRecovery(
        () async {
          expect(ImageDecodeBudget.inFlightCount, 0);
          ran = true;
        },
        isMounted: () => true,
      );

      expect(ran, isTrue);
      expect(MediaBudgetEpoch.listenable.value, before + 1);
    });

    test('bumps in finally even when work throws', () async {
      final before = MediaBudgetEpoch.listenable.value;

      await expectLater(
        () => runWithMediaBudgetRecovery(
          () async => throw StateError('refresh failed'),
          isMounted: () => true,
        ),
        throwsStateError,
      );

      expect(MediaBudgetEpoch.listenable.value, before + 1);
    });

    test('skips bump when unmounted', () async {
      final before = MediaBudgetEpoch.listenable.value;

      await runWithMediaBudgetRecovery(
        () async {},
        isMounted: () => false,
      );

      expect(MediaBudgetEpoch.listenable.value, before);
    });
  });

  group('ImagePaintBudget', () {
    testWidgets('paints at most one job per frame', (tester) async {
      final painted = <int>[];
      ImagePaintBudget.schedule(() => painted.add(1));
      ImagePaintBudget.schedule(() => painted.add(2));
      ImagePaintBudget.schedule(() => painted.add(3));

      expect(painted, [1]);

      await tester.pump();
      expect(painted, [1, 2]);

      await tester.pump();
      expect(painted, [1, 2, 3]);
    });

    test('clearPending drops queued paints', () {
      ImagePaintBudget.schedule(() {});
      ImagePaintBudget.schedule(() {});
      expect(ImagePaintBudget.queueLength, greaterThan(0));
      ImagePaintBudget.clearPending(notify: false);
      expect(ImagePaintBudget.queueLength, 0);
    });
  });
}
