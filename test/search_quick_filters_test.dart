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

    // Results are lazily built; the fourth medicine is below the viewport.
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Varfarin'), findsWidgets);
  });
  testWidgets('quick chips preserve Rx when selecting HZZO and vice versa',
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

    final quick = find.byKey(const Key('medicationQuickFilters'));
    final rx = find.descendant(of: quick, matching: find.text('Na recept'));
    await tester.tap(rx);
    await tester.pumpAndSettle();
    expect(find.text('Varfarin'), findsWidgets);

    final basic =
        find.descendant(of: quick, matching: find.text('Osnovna HZZO'));
    await tester.ensureVisible(basic);
    await tester.tap(basic);
    await tester.pumpAndSettle();

    // Fixtures have Rx medicines but none with confirmed HZZO coverage.
    // If the HZZO chip silently reset Rx, there would still be a mismatch
    // between selected chips and the actual composed query.
    expect(find.text('Varfarin'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is InputChip && widget.label is Text &&
            (widget.label as Text).data == 'Na recept',
      ),
      findsOneWidget,
    );

    // The horizontal quick-filter list lazily unmounts chips offscreen.
    // Return to the beginning before tapping Rx again.
    await tester.drag(quick, const Offset(540, 0));
    await tester.pumpAndSettle();
    expect(rx, findsOneWidget);
    await tester.tap(rx);
    await tester.pumpAndSettle();
    expect(find.text('Varfarin'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is InputChip && widget.label is Text &&
            (widget.label as Text).data == 'Osnovna lista',
      ),
      findsOneWidget,
    );

    final all = find.descendant(of: quick, matching: find.text('Svi'));
    await tester.ensureVisible(all);
    await tester.tap(all);
    await tester.pumpAndSettle();
    expect(find.text('Paracetamol'), findsWidgets);
  });

}
