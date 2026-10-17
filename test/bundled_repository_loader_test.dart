import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/bundled_repository_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads real bundled HALMED/HZZO/price catalogs without UI work',
      () async {
    final repository = await loadBundledMedicineRepository();

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
