import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/home/app_shell.dart';
import 'package:medix/features/medications/medication_detail_screen.dart';
import 'package:medix/features/onboarding/onboarding_screen.dart';
import 'package:medix/state/medix_state.dart';
import 'package:medix/widgets/medix_page.dart';

import 'support/medication_fixtures.dart';

void main() {
  final localizations = <LocalizationsDelegate<dynamic>>[
    MedixLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  void setCompactScreen(WidgetTester tester, {double height = 700}) {
    tester.view.physicalSize = Size(320, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(Widget home, {double textScale = 1.7}) {
    return MaterialApp(
      theme: MedixTheme.dark(),
      locale: const Locale('hr'),
      supportedLocales: MedixLanguages.locales,
      localizationsDelegates: localizations,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    );
  }

  testWidgets('all five primary tabs work at 320dp with larger text',
      (tester) async {
    setCompactScreen(tester);
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    await tester.pumpWidget(app(AppShell(state: state)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final tab in [1, 2, 3, 4, 0]) {
      final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
      nav.onDestinationSelected!(tab);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'Kartica $tab mora raditi pri uvećanju 170 %');
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        tab,
      );
    }
  });

  testWidgets('medicine details remain scrollable at 320dp and 170%',
      (tester) async {
    setCompactScreen(tester);
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    final medicine = state.repository.medications.first;
    await tester.pumpWidget(app(
      MedicationDetailScreen(medication: medicine, state: state),
    ));
    await tester.pumpAndSettle();
    expect(find.text(medicine.name), findsWidgets);
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('onboarding has no overflow at 320dp and 180% text',
      (tester) async {
    setCompactScreen(tester, height: 600);
    final state = MedixState(repository: buildTestRepository());
    addTearDown(state.dispose);
    await tester.pumpWidget(
      app(OnboardingScreen(state: state), textScale: 1.8),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final next = find.text('Dalje');
    if (next.evaluate().isNotEmpty) {
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('interactive card has at least 48dp tap target',
      (tester) async {
    setCompactScreen(tester);
    var clicks = 0;
    await tester.pumpWidget(app(
      Scaffold(
        body: Center(
          child: MedixSectionCard(
            onTap: () => clicks++,
            padding: EdgeInsets.zero,
            child: const Text('Otvori'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(InkWell)).height, greaterThanOrEqualTo(48));
    await tester.tap(find.text('Otvori'));
    expect(clicks, 1);
  });
}
