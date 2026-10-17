import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/services/medix_export_service.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a ZIP containing three valid PDF documents', () async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);

    state.toggleFavorite('paracetamol-500');
    state.addTherapy(
      medicationId: 'paracetamol-500',
      doseDescription: '1 tablet',
      times: const ['08:00'],
    );

    final bytes = await MedixExportService().buildZip(state);
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final files = {
      for (final file in archive.files) file.name: file,
    };

    expect(files.keys, containsAll(<String>[
      'therapy-plan.pdf',
      'favorites.pdf',
      'medix-app-info.pdf',
    ]));

    for (final name in files.keys) {
      final content = files[name]!.content;
      expect(utf8.decode(content.sublist(0, 4)), '%PDF');
    }
  });
}
