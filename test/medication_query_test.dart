import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/medication_query.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/medication_price.dart';

void main() {
  final reviewed = DateTime(2026, 10, 2);

  Medication medication({
    required String id,
    required String name,
    required String ingredient,
    bool? prescription,
    ReimbursementStatus reimbursement = ReimbursementStatus.none,
    String? atc,
    String form = 'tablete',
    String? holder,
    String? manufacturer,
    String? dispensingStatus,
    String? marketStatus,
    String? shortageStatus,
    List<MedicationPrice> prices = const [],
  }) {
    return Medication(
      id: id,
      name: name,
      activeIngredient: ingredient,
      strength: '10 mg',
      form: form,
      category: 'Test',
      requiresPrescription: prescription,
      summary: '',
      uses: const [],
      dosageGuidance: '',
      sideEffects: const [],
      warnings: const [],
      sourceLabel: 'test',
      lastReviewed: reviewed,
      reimbursementStatus: reimbursement,
      atcCode: atc,
      marketingAuthorizationHolder: holder,
      manufacturer: manufacturer,
      dispensingStatus: dispensingStatus,
      marketStatus: marketStatus,
      shortageStatus: shortageStatus,
      prices: prices,
    );
  }

  MedicationPrice price(
    double amount,
    MedicationPriceKind kind,
  ) {
    return MedicationPrice(
      amount: amount,
      currency: 'EUR',
      kind: kind,
      source: 'test',
      validFrom: reviewed,
    );
  }

  final catalog = [
    medication(
      id: 'a',
      name: 'Čisti lijek',
      ingredient: 'Tvar Alfa',
      prescription: true,
      reimbursement: ReimbursementStatus.basic,
      atc: 'C09AA01',
      holder: 'Alfa Pharma',
      manufacturer: 'Alfa Manufacturing',
      dispensingStatus: 'na recept',
      marketStatus: 'stavljeno u promet',
      shortageStatus: 'nema nestašice',
      prices: [
        price(2.5, MedicationPriceKind.hzzoCopay),
      ],
    ),
    medication(
      id: 'b',
      name: 'Beta',
      ingredient: 'Tvar Beta',
      prescription: false,
      reimbursement: ReimbursementStatus.supplementary,
      atc: 'R06AX01',
      form: 'sirup',
      holder: 'Beta Pharma',
      marketStatus: 'nije stavljeno u promet',
      shortageStatus: 'nestašica',
      prices: [
        price(8, MedicationPriceKind.maxWholesale),
      ],
    ),
    medication(
      id: 'c',
      name: 'Gamma',
      ingredient: 'Tvar Gamma',
      atc: 'N02BE01',
      holder: 'Gamma Pharma',
      marketStatus: 'privremeni prekid opskrbe',
    ),
    medication(
      id: 'd',
      name: 'Delta',
      ingredient: 'Tvar Delta',
      atc: 'A01AB09; R05CA12',
      holder: 'Delta Pharma',
    ),
  ];

  test('text search is tokenized and diacritic-insensitive', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(text: 'cisti alfa'),
    );

    expect(result.map((item) => item.id), ['a']);
  });

  test('filters prescription and reimbursement status', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(
        dispensing: DispensingFilter.prescription,
        reimbursement: ReimbursementFilter.basic,
      ),
    );

    expect(result.map((item) => item.id), ['a']);
  });

  test('can explicitly filter unknown dispensing status', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(
        dispensing: DispensingFilter.unknown,
      ),
    );

    expect(result.map((item) => item.id), ['d', 'c']);
  });

  test('filters ATC group, form and holder', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(
        atcGroup: 'R',
        form: 'sirup',
        holder: 'Beta Pharma',
      ),
    );

    expect(result.map((item) => item.id), ['b']);
  });

  test('ATC filter checks every ATC code in a record', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(atcGroup: 'R'),
    );

    expect(result.map((item) => item.id), ['b', 'd']);
  });

  test('holder/manufacturer filter checks both fields', () {
    final byManufacturer = applyMedicationQuery(
      catalog,
      const MedicationQuery(holder: 'Alfa Manufacturing'),
    );

    expect(byManufacturer.map((item) => item.id), ['a']);
  });

  test('text search includes detailed dispensing metadata', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(text: 'na recept'),
    );

    expect(result.map((item) => item.id), ['a']);
  });

  test('filters by HALMED market status', () {
    final marketed = applyMedicationQuery(
      catalog,
      const MedicationQuery(market: MarketFilter.marketed),
    );
    final notMarketed = applyMedicationQuery(
      catalog,
      const MedicationQuery(market: MarketFilter.notMarketed),
    );
    final interrupted = applyMedicationQuery(
      catalog,
      const MedicationQuery(
        market: MarketFilter.temporaryInterruption,
      ),
    );

    expect(marketed.map((item) => item.id), ['a']);
    expect(notMarketed.map((item) => item.id), ['b']);
    expect(interrupted.map((item) => item.id), ['c']);
  });

  test('filters HALMED shortage status', () {
    final reported = applyMedicationQuery(
      catalog,
      const MedicationQuery(shortage: ShortageFilter.reported),
    );
    final noneReported = applyMedicationQuery(
      catalog,
      const MedicationQuery(
        shortage: ShortageFilter.noneReported,
      ),
    );
    final unknown = applyMedicationQuery(
      catalog,
      const MedicationQuery(shortage: ShortageFilter.unknown),
    );

    expect(reported.map((item) => item.id), ['b']);
    expect(noneReported.map((item) => item.id), ['a']);
    expect(unknown.map((item) => item.id), ['d', 'c']);
  });

  test('filters only validated prices, not a raw HZZO copay on basic list', () {
    final copay = applyMedicationQuery(
      catalog,
      const MedicationQuery(price: PriceFilter.copay),
    );
    final wholesale = applyMedicationQuery(
      catalog,
      const MedicationQuery(price: PriceFilter.wholesale),
    );
    final anyPrice = applyMedicationQuery(
      catalog,
      const MedicationQuery(price: PriceFilter.anyPrice),
    );

    expect(copay, isEmpty);
    expect(wholesale.map((item) => item.id), ['b']);
    expect(anyPrice.map((item) => item.id), ['b']);
  });

  test('unverified list filter never asserts that the medicine is not covered', () {
    final results = applyMedicationQuery(
      catalog,
      const MedicationQuery(reimbursement: ReimbursementFilter.unverified),
    );
    expect(results.map((item) => item.id), ['d', 'c']);
  });

  test('does not compare HZZO copay with wholesale amounts', () {
    final verifiedCopay = medication(
      id: 'verified-copay',
      name: 'B-Copay',
      ingredient: 'Tvar C',
      reimbursement: ReimbursementStatus.supplementary,
      prices: [price(9, MedicationPriceKind.hzzoCopay)],
    );
    final cheaperCopay = medication(
      id: 'cheap-copay',
      name: 'Z-Copay',
      ingredient: 'Tvar Z',
      reimbursement: ReimbursementStatus.supplementary,
      prices: [price(2, MedicationPriceKind.hzzoCopay)],
    );
    final medicines = [...catalog, verifiedCopay, cheaperCopay];

    final copayAsc = applyMedicationQuery(
      medicines,
      const MedicationQuery(sort: MedicationSort.copayAsc),
    );
    final copayDesc = applyMedicationQuery(
      medicines,
      const MedicationQuery(sort: MedicationSort.copayDesc),
    );
    final wholesaleAsc = applyMedicationQuery(
      medicines,
      const MedicationQuery(sort: MedicationSort.wholesaleAsc),
    );

    expect(copayAsc.take(2).map((item) => item.id),
        ['cheap-copay', 'verified-copay']);
    expect(copayDesc.take(2).map((item) => item.id),
        ['verified-copay', 'cheap-copay']);
    expect(wholesaleAsc.first.id, 'b');
    expect(wholesaleAsc.skip(1).every((item) => item.id != 'b'), isTrue);
  });

  test('rejects non-EUR, negative and non-finite prices in search', () {
    final wrongCurrency = MedicationPrice(
      amount: 3.5,
      currency: 'HRK',
      kind: MedicationPriceKind.hzzoCopay,
      source: 'test',
      validFrom: reviewed,
    );
    final invalid = medication(
      id: 'invalid',
      name: 'Invalid',
      ingredient: 'Test',
      reimbursement: ReimbursementStatus.supplementary,
      prices: [
        wrongCurrency,
        price(-1, MedicationPriceKind.hzzoCopay),
        price(double.nan, MedicationPriceKind.maxWholesale),
      ],
    );
    final result = applyMedicationQuery(
      [invalid],
      const MedicationQuery(price: PriceFilter.anyPrice),
    );
    expect(result, isEmpty);
  });

  test('precomputed index returns identical results for clinical queries', () {
    final index = MedicationSearchIndex(catalog);
    const queries = <MedicationQuery>[
      MedicationQuery(text: 'cisti alfa'),
      MedicationQuery(text: 'čisti 10 mg'),
      MedicationQuery(text: 'varfarin'),
      MedicationQuery(text: 'C09AA01'),
      MedicationQuery(text: 'na recept', dispensing: DispensingFilter.prescription),
      MedicationQuery(text: 'tvar', reimbursement: ReimbursementFilter.basic),
      MedicationQuery(text: 'tvar', sort: MedicationSort.ingredientAsc),
      MedicationQuery(text: 'tvar', sort: MedicationSort.wholesaleAsc),
      MedicationQuery(text: 'NO MATCH'),
      MedicationQuery(text: ''),
    ];
    for (final query in queries) {
      final original = applyMedicationQuery(catalog, query);
      final indexed = applyMedicationQuery(catalog, query, index: index);
      expect(
        indexed.map((medicine) => medicine.id),
        original.map((medicine) => medicine.id),
        reason: 'Indexed and original queries must match: ${query.text}',
      );
    }
  });

  test('search index safely falls back for records added after indexing', () {
    final index = MedicationSearchIndex(catalog);
    final extra = medication(
      id: 'new',
      name: 'Novija terapija',
      ingredient: 'nova tvar',
    );
    final result = applyMedicationQuery(
      [...catalog, extra],
      const MedicationQuery(text: 'novija'),
      index: index,
    );
    expect(result.map((item) => item.id), ['new']);
  });

}
