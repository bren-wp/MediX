import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/search/search_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  testWidgets('one-tap prescription and OTC filters apply without dialog',
      (tester) async {
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
        home: SearchScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();

    final filters = find.byKey(const Key('medicationQuickFilters'));
    expect(filters, findsOneWidget);
    final prescription = find.descendant(
      of: filters,
      matching: find.text('Na recept'),
    );
    await tester.tap(prescription);
    await tester.pumpAndSettle();

    expect(find.text('Varfarin'), findsWidgets);
    expect(find.text('Paracetamol'), findsNothing);

    final otc = find.descendant(
      of: filters,
      matching: find.text('Bez recepta'),
    );
    await tester.tap(otc);
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol'), findsWidgets);
    expect(find.text('Varfarin'), findsNothing);

    final all = find.descendant(
      of: filters,
      matching: find.text('Svi'),
    );
    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol'), findsWidgets);
    expect(find.text('Varfarin'), findsWidgets);
  });
}
