import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/search/search_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  testWidgets('search and advanced filters fit 320px with large Android text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.7),
          ),
          child: child!,
        ),
        home: SearchScreen(state: state),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Filters must remain reachable without horizontal layout overflow.
    final filters = find.byType(FilledButton);
    expect(filters, findsWidgets);
    await tester.tap(filters.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
