import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('run_calledMultipleTimesQuickly_invokesActionOnlyOnce', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 30));
      var callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(callCount, 1);
      debouncer.dispose();
    });

    test('run_calledAfterDurationElapsed_invokesActionEachTime', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var callCount = 0;

      debouncer.run(() => callCount++);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      debouncer.run(() => callCount++);
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(callCount, 2);
      debouncer.dispose();
    });

    test('dispose_cancelsPendingAction', () async {
      final debouncer = Debouncer(duration: const Duration(milliseconds: 20));
      var callCount = 0;

      debouncer.run(() => callCount++);
      debouncer.dispose();

      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(callCount, 0);
    });
  });
}
