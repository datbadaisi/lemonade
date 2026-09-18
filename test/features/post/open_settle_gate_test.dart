import 'package:flutter_test/flutter_test.dart';
import 'package:bluerum/features/post/presentation/open_settle_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OpenSettleGate', () {
    testWidgets('settles once after quiet duration', (tester) async {
      final gate = OpenSettleGate(
        duration: const Duration(milliseconds: 20),
      );
      var settledCount = 0;
      gate.schedule(
        isMounted: () => true,
        onSettled: () => settledCount++,
      );

      expect(gate.settled, isFalse);
      await tester.pump(const Duration(milliseconds: 20));
      expect(gate.settled, isTrue);
      expect(settledCount, 1);

      // Second complete is a no-op.
      gate.complete(onSettled: () => settledCount++);
      expect(settledCount, 1);

      gate.dispose();
    });

    test('whenSettled completes on dispose', () async {
      final gate = OpenSettleGate(
        duration: const Duration(hours: 1),
      );
      gate.schedule(isMounted: () => true, onSettled: () {});
      final future = gate.whenSettled;
      gate.dispose();
      await expectLater(future, completes);
      // dispose completes waiters without marking settled (caller is gone).
      expect(gate.settled, isFalse);
    });

    test('complete marks settled and resolves whenSettled', () async {
      final gate = OpenSettleGate(
        duration: const Duration(hours: 1),
      );
      final future = gate.whenSettled;
      var ran = false;
      gate.complete(onSettled: () => ran = true);
      expect(gate.settled, isTrue);
      expect(ran, isTrue);
      await expectLater(future, completes);
      gate.dispose();
    });

    test('does not settle when unmounted at timer fire', () async {
      final gate = OpenSettleGate(
        duration: const Duration(milliseconds: 10),
      );
      var ran = false;
      gate.schedule(isMounted: () => false, onSettled: () => ran = true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(gate.settled, isFalse);
      expect(ran, isFalse);
      gate.dispose();
    });
  });
}
