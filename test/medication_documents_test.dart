import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/medications/medication_documents_panel.dart';

import 'support/medication_fixtures.dart';

void main() {
  test('official document URL validation rejects spoofed and unsafe hosts',
      () {
    final valid = [
      'https://www.halmed.hr/Lijekovi/Baza-lijekova/',
      'https://lijekovi.halmed.hr/docs/sample.pdf',
      'https://www.ema.europa.eu/documents/leaflet.pdf',
    ];
    final rejected = [
      'http://www.halmed.hr/Lijekovi/Baza-lijekova/',
      'https://halmed.hr.attacker.example/leaflet.pdf',
      'https://evil.example/?redirect=halmed.hr',
      'https://user:pass@www.halmed.hr/leaflet.pdf',
      'file:///private/doc.pdf',
      'javascript:alert(1)',
      'https://www.halmed.hr:8080/doc.pdf',
      '',
    ];
    for (final url in valid) {
      expect(MedicationDocumentsPanel.isTrustedSourceUrl(url), isTrue,
          reason: url);
    }
    for (final url in rejected) {
      expect(MedicationDocumentsPanel.isTrustedSourceUrl(url), isFalse,
          reason: url);
    }
    expect(MedicationDocumentsPanel.isTrustedSourceUrl(null), isFalse);
  });

  testWidgets('only supplied official links offer direct documents',
      (tester) async {
    final medicine = testMedication(
      id: 'test-document',
      name: 'Sample 500 mg',
      ingredient: 'Sample',
    ).copyWith(
      patientLeafletUrl: 'https://www.halmed.hr/docs/patient.pdf',
      smpcUrl: 'https://www.halmed.hr/docs/professional.pdf',
      officialRecordUrl: 'https://halmed.hr.attacker.example/fake',
    );

    const channel = MethodChannel('com.brendigo.medix/navigation');
    final opened = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        if (call.method == 'openExternalUrl') {
          opened.add((call.arguments as Map)['url'] as String);
          return true;
        }
        return false;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        supportedLocales: MedixLanguages.locales,
        locale: const Locale('en'),
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationDocumentsPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Patient leaflet'), findsOneWidget);
    expect(find.text('Professional product information'), findsOneWidget);
    expect(find.text('Official source'), findsNothing);
    expect(find.text('Search HALMED database'), findsOneWidget);

    await tester.tap(find.text('Patient leaflet'));
    await tester.pumpAndSettle();
    expect(opened, ['https://www.halmed.hr/docs/patient.pdf']);
  });

  testWidgets('unknown document URLs do not create fictional PDF buttons',
      (tester) async {
    final medicine = testMedication(
      id: 'no-doc',
      name: 'Sample',
      ingredient: 'Sample',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        supportedLocales: MedixLanguages.locales,
        locale: const Locale('hr'),
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationDocumentsPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Uputa o lijeku'), findsNothing);
    expect(find.text('Sažetak opisa svojstava lijeka'), findsNothing);
    expect(find.text('Pretraži HALMED bazu'), findsOneWidget);
  });
}
