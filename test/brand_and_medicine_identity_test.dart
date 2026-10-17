import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/app_info.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/medications/medication_detail_screen.dart';
import 'package:medix/features/settings/about_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  Widget app(Widget page) => MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('hr'),
        supportedLocales: MedixLanguages.locales,
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: page,
      );

  testWidgets('Naziv lijeka ostaje vidljiv u detaljima', (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    final medicine = state.medicationById('paracetamol-500')!;
    await tester.pumpWidget(
      app(MedicationDetailScreen(medication: medicine, state: state)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol'), findsWidgets);
    expect(medicine.activeIngredient, 'Paracetamol');
    expect(medicine.strength, '500 mg');
  });

  testWidgets('Brendigo i brendigo.com ostaju dostupni u aplikaciji',
      (tester) async {
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
    await tester.pumpWidget(app(const AboutScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Brendigo'), findsWidgets);
    final website = find.text('brendigo.com');
    // AboutScreen uses a lazily built ListView, so scroll to the bottom
    // before testing the developer's external website button.
    await tester.scrollUntilVisible(
      website,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(website, findsOneWidget);
    expect(MedixAppInfo.developerWebsiteUrl, 'https://brendigo.com');
    await tester.ensureVisible(website);
    await tester.tap(website);
    await tester.pumpAndSettle();
    expect(opened, ['https://brendigo.com']);
  });
}
