import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/classifications/classifications_screen.dart';
import 'package:medix/features/clinical/clinical_tools_screen.dart';
import 'package:medix/features/compare/medication_compare_screen.dart';
import 'package:medix/features/interactions/interactions_screen.dart';
import 'package:medix/features/news/news_screen.dart';
import 'package:medix/features/pharmacies/pharmacies_screen.dart';
import 'package:medix/features/prices/price_catalog_screen.dart';
import 'package:medix/features/safety/special_population_screen.dart';
import 'package:medix/features/settings/about_screen.dart';
import 'package:medix/features/settings/settings_screen.dart';
import 'package:medix/features/smart/smart_search_screen.dart';
import 'package:medix/features/substitutions/substitutions_screen.dart';
import 'package:medix/features/therapy/calendar_screen.dart';
import 'package:medix/state/medix_state.dart';

import 'support/medication_fixtures.dart';

void main() {
  final screens = <(String, Widget Function(MedixState))>[
    ('MediX Smart', (state) => SmartSearchScreen(state: state)),
    ('Interakcije', (state) => InteractionsScreen(state: state)),
    ('Usporedba', (state) => MedicationCompareScreen(state: state)),
    ('Klinički alati', (_) => const ClinicalToolsScreen()),
    ('Klasifikacije', (state) => ClassificationsScreen(state: state)),
    ('Srodni lijekovi', (state) => SubstitutionsScreen(state: state)),
    ('Cijene', (_) => const PriceCatalogScreen()),
    ('Kalendar', (state) => TherapyCalendarScreen(state: state)),
    ('Trudnoća', (_) => const SpecialPopulationScreen(
          population: SpecialPopulation.pregnancy,
        )),
    ('Djeca', (_) => const SpecialPopulationScreen(
          population: SpecialPopulation.children,
        )),
    ('Starije osobe', (_) => const SpecialPopulationScreen(
          population: SpecialPopulation.olderAdults,
        )),
    ('Ljekarne', (_) => const PharmaciesScreen()),
    ('Edukacija', (_) => const NewsScreen()),
    ('Postavke', (state) => SettingsScreen(state: state)),
    ('O aplikaciji', (_) => const AboutScreen()),
  ];

  for (final screen in screens) {
    testWidgets('${screen.$1} works at 320dp and 170% Croatian text',
        (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = MedixState(repository: buildTestRepository());
      addTearDown(state.dispose);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('hr'),
          theme: MedixTheme.dark(),
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
          home: screen.$2(state),
        ),
      );
      // The price catalog loads a bundled multi-megabyte asset
      // asynchronously. Its progress indicator intentionally animates
      // continuously until the asset is ready; a fake-async widget test
      // must not wait for that spinner to "settle".
      if (screen.$1 == 'Cijene') {
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull);
        return;
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: '${screen.$1} must render without Flutter errors');

      final scroll = find.byType(ListView);
      if (scroll.evaluate().isNotEmpty) {
        await tester.drag(scroll.first, const Offset(0, -180));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull,
            reason: '${screen.$1} must remain stable while scrolling');
      }
    });
  }
}
