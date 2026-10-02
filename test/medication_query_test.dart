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

    expect(result.map((item) => item.id), ['a', 'b', 'd', 'c']);
  });
}
