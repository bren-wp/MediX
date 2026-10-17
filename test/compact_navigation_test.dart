import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/home/app_shell.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  testWidgets('five destinations stay usable at 320px with 1.7x font',
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
        home: AppShell(state: state),
      ),
    );
    await tester.pumpAndSettle();

    var navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      navigation.labelBehavior,
      NavigationDestinationLabelBehavior.onlyShowSelected,
    );
    expect(navigation.destinations, hasLength(5));

    for (final position in <int>[1, 2, 3, 4, 0]) {
      navigation.onDestinationSelected!(position);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigation.selectedIndex, position);
    }
  });
}
