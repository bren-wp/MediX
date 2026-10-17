import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/therapy/therapy_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget app(MedixState state) => MaterialApp(
        locale: const Locale('hr'),
        supportedLocales: MedixLanguages.locales,
        localizationsDelegates: const [
          MedixLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: MedixTheme.dark(),
        home: TherapyScreen(state: state),
      );

  testWidgets('new therapy requires explicit medicine selection',
      (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    await tester.pumpWidget(app(state));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('therapyMedicineSelect')), findsOneWidget);
    expect(find.text('Odaberite lijek i pakiranje'), findsWidgets);
    expect(find.text('Paracetamol'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('search chooses an exact medicine rather than an arbitrary row',
      (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    await tester.pumpWidget(app(state));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('therapyMedicineSelect')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('therapyMedicineSearch')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('therapyMedicineSearch')), 'varfarin',
    );
    await tester.pumpAndSettle();
    expect(find.text('Varfarin'), findsOneWidget);
    expect(find.text('Paracetamol'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('medicine-pick-warfarin')));
    await tester.pumpAndSettle();
    expect(find.text('Varfarin'), findsOneWidget);
    expect(state.therapy, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recent and favorite medicines appear as suggestions',
      (tester) async {
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    state.markViewed('ibuprofen-400');
    state.toggleFavorite('loratadine-10');
    await tester.pumpWidget(app(state));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('therapyMedicineSelect')));
    await tester.pumpAndSettle();

    expect(find.text('Ibuprofen'), findsOneWidget);
    expect(find.text('Loratadin'), findsOneWidget);
    expect(find.text('Paracetamol'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
