import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Medicinski profili ne prikazuju vanjske poveznice', () {
    final detail = File(
      'lib/features/medications/medication_detail_screen.dart',
    ).readAsStringSync();
    final access = File(
      'lib/features/medications/medication_access_panel.dart',
    ).readAsStringSync();
    final more = File(
      'lib/features/settings/more_screen.dart',
    ).readAsStringSync();

    expect(detail, isNot(contains('MedicationDocumentsPanel')));
    expect(access, isNot(contains('openExternalUrl')));
    expect(access, isNot(contains('officialHzzoListUrl')));
    expect(more, isNot(contains('SourcesScreen')));
  });

  test('Podaci o podrijetlu i datumima ostaju u modelu lijeka', () {
    final model = File('lib/models/medication.dart').readAsStringSync();
    expect(model, contains('sourceLabel'));
    expect(model, contains('hzzoListEffectiveDate'));
    expect(model, contains('officialRecordUrl'));
  });
}
