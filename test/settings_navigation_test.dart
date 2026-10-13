import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
        locale: const Locale('en'),
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

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    final privacy = find.text('Security & privacy');
    await tester.ensureVisible(privacy);
    await tester.tap(privacy);
    await tester.pumpAndSettle();

    expect(find.text('No mandatory account'), findsOneWidget);
    expect(find.text('Private local data'), findsWidgets);
  });

  testWidgets('Settings provides working language selection', (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('en'),
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

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    final croatian = find.text('Hrvatski').last;
    await tester.ensureVisible(croatian);
    await tester.tap(croatian);
    await tester.pumpAndSettle();

    expect(state.localeCode, 'hr');
  });
}
