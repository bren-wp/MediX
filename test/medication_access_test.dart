import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        locale: const Locale('en'),
        localizationsDelegates: const [MedixLocalizations.delegate],
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prescription & medicine costs'), findsOneWidget);
    expect(find.textContaining('Available without a prescription'),
        findsOneWidget);
    expect(find.textContaining('No confirmed HZZO list match'),
        findsOneWidget);
    expect(find.text('Amount not confirmed'), findsOneWidget);
    expect(find.textContaining('Not available in official offline data'),
        findsOneWidget);
    expect(find.textContaining('zero-euro cost cannot be assumed'),
        findsOneWidget);
  });

  testWidgets('HZZO source failure shows feedback instead of crashing',
      (tester) async {
    final medicine = testMedication(
      id: 'offline-link',
      name: 'Test Medicine',
      ingredient: 'Test',
    );
    const channel = MethodChannel('com.brendigo.medix/navigation');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'NO_HANDLER'),
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: const [MedixLocalizations.delegate],
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('View official HZZO medicine lists'));
    await tester.pumpAndSettle();
    expect(
      find.text('This link could not be opened on this device.'),
      findsOneWidget,
    );
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
      hzzoListSource: 'HZZO official list',
      hzzoListEffectiveDate: DateTime(2026, 10, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: MedixTheme.dark(),
        locale: const Locale('en'),
        localizationsDelegates: const [MedixLocalizations.delegate],
        home: Scaffold(
          body: SingleChildScrollView(
            child: MedicationAccessPanel(medication: medicine),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('HZZO official list · Effective from 01.10.2026.'),
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
        localizationsDelegates: const [MedixLocalizations.delegate],
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

  test('Croatian pricing explanation has its own translation', () {
    const hr = MedixLocalizations(Locale('hr'));
    const en = MedixLocalizations(Locale('en'));
    const de = MedixLocalizations(Locale('de'));
    for (final key in const [
      'accessTitle',
      'accessCopaymentLabel',
      'accessPolicyVaries',
      'accessWholesaleLabel',
    ]) {
      expect(hr.t(key), isNot(key));
      expect(en.t(key), isNot(key));
      expect(de.t(key), en.t(key));
    }
  });
}
