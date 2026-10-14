import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/home/home_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  testWidgets('home action and category grids fit 320px accessible Android UI',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);

    var searchTapped = false;
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.7),
          ),
          child: child!,
        ),
        home: HomeScreen(
          state: state,
          onSearchRequested: () => searchTapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The first action must remain accessible without scrolling sideways.
    await tester.tap(find.text('Svi lijekovi'));
    expect(searchTapped, isTrue);

    final homeList = find.byType(ListView).first;
    await tester.drag(homeList, const Offset(0, -480));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(homeList, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(homeList, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
