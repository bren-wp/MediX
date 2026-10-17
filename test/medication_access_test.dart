import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';
import 'package:medix/core/theme/medix_theme.dart';
import 'package:medix/features/medications/medication_access_panel.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_access.dart';
import 'package:medix/models/medication_price.dart';

import 'support/medication_fixtures.dart';

void main() {
  final sourceDate = DateTime(2026, 10, 1);
  MedicationPrice price(MedicationPriceKind kind, double amount) =>
      MedicationPrice(
        amount: amount,
        currency: 'EUR',
        kind: kind,
        source: 'HZZO',
        validFrom: sourceDate,
      );

  test('only a supplementary-list record exposes HZZO copayment', () {
    final base = testMedication(
      id: 'test-1',
      name: 'Test medicine',
      ingredient: 'Ingredient',
      prescription: true,
    );
    final basic = base.copyWith(
      reimbursementStatus: ReimbursementStatus.basic,
      prices: [price(MedicationPriceKind.hzzoCopay, 4.25)],
    );
    final supplementary = base.copyWith(
      reimbursementStatus: ReimbursementStatus.supplementary,
      prices: [price(MedicationPriceKind.hzzoCopay, 4.25)],
    );
    final unknown = base.copyWith(
      reimbursementStatus: ReimbursementStatus.none,
      prices: [price(MedicationPriceKind.hzzoCopay, 4.25)],
    );

    expect(MedicationAccessInfo.fromMedication(basic).copayment, isNull);
    expect(
      MedicationAccessInfo.fromMedication(supplementary).copayment?.amount,
      4.25,
    );
    expect(MedicationAccessInfo.fromMedication(unknown).copayment, isNull);
    expect(MedicationAccessInfo.fromMedication(unknown).hasConfirmedHzzoList,
        isFalse);
  });

  test('wholesale price never becomes a pharmacy retail price', () {
    final medicine = testMedication(
      id: 'test-2',
      name: 'Test medicine',
      ingredient: 'Ingredient',
    ).copyWith(prices: [price(MedicationPriceKind.maxWholesale, 9.95)]);

    final info = MedicationAccessInfo.fromMedication(medicine);
    expect(info.wholesalePrice?.amount, 9.95);
    expect(info.retailPrice, isNull);
  });

  test('invalid, non-euro and negative prices are not displayed', () {
    final medicine = testMedication(
      id: 'test-3',
      name: 'Test medicine',
      ingredient: 'Ingredient',
    ).copyWith(
      reimbursementStatus: ReimbursementStatus.supplementary,
      prices: [
        price(MedicationPriceKind.hzzoCopay, -1),
        price(MedicationPriceKind.hzzoCopay, double.nan),
        MedicationPrice(
          amount: 12,
          currency: 'HRK',
          kind: MedicationPriceKind.hzzoCopay,
          source: 'test',
          validFrom: sourceDate,
        ),
      ],
    );
    expect(MedicationAccessInfo.fromMedication(medicine).copayment, isNull);
  });

  testWidgets('unknown HZZO status never presents a fabricated amount',
      (tester) async {
    final medicine = testMedication(
      id: 'test-4',
      name: 'Test medicine',
      ingredient: 'Ingredient',
      prescription: false,
    );
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recept i cijena lijeka'), findsOneWidget);
    expect(find.textContaining('Može se izdati bez recepta'),
        findsOneWidget);
    expect(find.textContaining('Nema potvrđenog HZZO podudaranja'),
        findsOneWidget);
    expect(find.text('Iznos nije potvrđen'), findsOneWidget);
    expect(find.textContaining('Nije dostupna u službenim offline podacima'),
        findsOneWidget);
    expect(find.textContaining('Iznosi se odnose na upareno pakiranje'),
        findsOneWidget);
  });

  testWidgets('HZZO kartica nema vanjsku poveznicu na bazu lijekova',
      (tester) async {
    final medicine = testMedication(
      id: 'offline-link',
      name: 'Paracetamol',
      ingredient: 'Paracetamol',
    );
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
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recept i cijena lijeka'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matched HZZO status shows its own source and effective date',
      (tester) async {
    final medicine = testMedication(
      id: 'hzzo-dated',
      name: 'Dated medicine',
      ingredient: 'Active',
    ).copyWith(
      reimbursementStatus: ReimbursementStatus.basic,
      hzzoListSource: 'HZZO službena lista',
      hzzoListEffectiveDate: DateTime(2026, 10, 1),
    );

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
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('HZZO službena lista · U primjeni od 01.10.2026.'),
      findsOneWidget,
    );
  });

  testWidgets('missing HZZO date is explicitly unverified',
      (tester) async {
    final medicine = testMedication(
      id: 'hzzo-undated',
      name: 'Undated medicine',
      ingredient: 'Active',
    ).copyWith(
      reimbursementStatus: ReimbursementStatus.supplementary,
      hzzoListSource: 'HZZO test',
    );

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
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Datum primjene nije potvrđen'), findsOneWidget);
    expect(find.text('Iznos nije potvrđen'), findsOneWidget);
  });

  test('Hrvatski prijevod svih ključnih cijena i naknada', () {
    const loc = MedixLocalizations(Locale('hr'));
    for (final key in const [
      'accessTitle',
      'accessCopaymentLabel',
      'accessPolicyVaries',
      'accessWholesaleLabel',
    ]) {
      expect(loc.t(key), isNot(key));
    }
  });
}
