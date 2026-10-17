import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/app_info.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/settings/settings_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  testWidgets('Settings opens Privacy information', (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('hr'),
        supportedLocales: MedixLanguages.locales,
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Postavke'), findsOneWidget);
    expect(find.text('Hrvatski jezik'), findsOneWidget);
    final privacy = find.text('Sigurnost i privatnost');
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pumpAndSettle();

    expect(find.text('Bez obveznog računa'), findsOneWidget);
    expect(find.text('Privatni lokalni podaci'), findsWidgets);
  });

  testWidgets('Settings opens MediX-specific legal URLs', (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);

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
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('hr'),
        supportedLocales: MedixLanguages.locales,
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();

    final privacy = find.text('Politika privatnosti');
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pumpAndSettle();

    final terms = find.text('Uvjeti korištenja');
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.pumpAndSettle();

    expect(opened, [
      MedixAppInfo.privacyPolicyUrl,
      MedixAppInfo.termsOfUseUrl,
    ]);
  });

  testWidgets('Postavke prikazuju samo hrvatski jezik', (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('hr'),
        supportedLocales: MedixLanguages.locales,
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SettingsScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hrvatski jezik'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(state.localeCode, 'hr');
  });
}
