import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/bundled_repository_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads real bundled HALMED/HZZO/price catalogs without UI work',
      () async {
    final stopwatch = Stopwatch()..start();
    final repository = await loadBundledMedicineRepository();
    stopwatch.stop();
    // Diagnostic only: real-device startup timings vary by CPU and storage.
    // Do not enforce a flaky wall-clock performance threshold in CI.
    // ignore: avoid_print
    print('MediX real bundled catalog load: ${stopwatch.elapsedMilliseconds} ms');

    expect(repository.medications.length, greaterThanOrEqualTo(4000));
    expect(
      repository.medications.map((medicine) => medicine.id).toSet().length,
      repository.medications.length,
    );
    expect(
      repository.medications.any(
        (medicine) => medicine.sourceLabel.toUpperCase().contains('HALMED'),
      ),
      isTrue,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));
}
