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
      prices: prices,
      isDemo: false,
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

    expect(result.map((item) => item.id), ['c']);
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

  test('filters by available price type', () {
    final copay = applyMedicationQuery(
      catalog,
      const MedicationQuery(price: PriceFilter.copay),
    );
    final wholesale = applyMedicationQuery(
      catalog,
      const MedicationQuery(price: PriceFilter.wholesale),
    );

    expect(copay.map((item) => item.id), ['a']);
    expect(wholesale.map((item) => item.id), ['b']);
  });

  test('sorts known prices before missing prices', () {
    final result = applyMedicationQuery(
      catalog,
      const MedicationQuery(sort: MedicationSort.priceAsc),
    );

    expect(result.map((item) => item.id), ['a', 'b', 'c']);
  });
}
