import '../models/medication.dart';
import '../models/medication_price.dart';

enum DispensingFilter {
  all,
  prescription,
  otc,
  unknown,
}

enum ReimbursementFilter {
  all,
  listed,
  basic,
  supplementary,
  notListed,
}

enum PriceFilter {
  all,
  anyPrice,
  copay,
  wholesale,
}

enum MedicationSort {
  nameAsc,
  ingredientAsc,
  atcAsc,
  priceAsc,
  priceDesc,
}

class MedicationQuery {
  const MedicationQuery({
    this.text = '',
    this.dispensing = DispensingFilter.all,
    this.reimbursement = ReimbursementFilter.all,
    this.price = PriceFilter.all,
    this.atcGroup,
    this.form,
    this.holder,
    this.sort = MedicationSort.nameAsc,
  });

  final String text;
  final DispensingFilter dispensing;
  final ReimbursementFilter reimbursement;
  final PriceFilter price;
  final String? atcGroup;
  final String? form;
  final String? holder;
  final MedicationSort sort;

  bool get hasFilters =>
      dispensing != DispensingFilter.all ||
      reimbursement != ReimbursementFilter.all ||
      price != PriceFilter.all ||
      atcGroup != null ||
      form != null ||
      holder != null;

  MedicationQuery copyWith({
    String? text,
    DispensingFilter? dispensing,
    ReimbursementFilter? reimbursement,
    PriceFilter? price,
    String? atcGroup,
    bool clearAtcGroup = false,
    String? form,
    bool clearForm = false,
    String? holder,
    bool clearHolder = false,
    MedicationSort? sort,
  }) {
    return MedicationQuery(
      text: text ?? this.text,
      dispensing: dispensing ?? this.dispensing,
      reimbursement: reimbursement ?? this.reimbursement,
      price: price ?? this.price,
      atcGroup: clearAtcGroup ? null : (atcGroup ?? this.atcGroup),
      form: clearForm ? null : (form ?? this.form),
      holder: clearHolder ? null : (holder ?? this.holder),
      sort: sort ?? this.sort,
    );
  }

  MedicationQuery clearFilters() {
    return MedicationQuery(
      text: text,
      sort: sort,
    );
  }
}

List<Medication> applyMedicationQuery(
  Iterable<Medication> medications,
  MedicationQuery query,
) {
  final normalizedText = _normalize(query.text);
  final normalizedAtc = query.atcGroup?.trim().toUpperCase();
  final normalizedForm = _normalize(query.form ?? '');
  final normalizedHolder = _normalize(query.holder ?? '');

  final result = medications.where((medication) {
    if (normalizedText.isNotEmpty &&
        !_matchesText(medication, normalizedText)) {
      return false;
    }

    if (!_matchesDispensing(medication, query.dispensing)) {
      return false;
    }

    if (!_matchesReimbursement(
      medication,
      query.reimbursement,
    )) {
      return false;
    }

    if (!_matchesPrice(medication, query.price)) {
      return false;
    }

    if (normalizedAtc != null &&
        normalizedAtc.isNotEmpty &&
        !(medication.atcCode ?? '')
            .toUpperCase()
            .startsWith(normalizedAtc)) {
      return false;
    }

    if (normalizedForm.isNotEmpty &&
        _normalize(medication.form) != normalizedForm) {
      return false;
    }

    if (normalizedHolder.isNotEmpty) {
      final holder = _normalize(
        medication.marketingAuthorizationHolder ?? '',
      );
      final manufacturer = _normalize(
        medication.manufacturer ?? '',
      );
      if (holder != normalizedHolder &&
          manufacturer != normalizedHolder) {
        return false;
      }
    }

    return true;
  }).toList(growable: false);

  final sorted = List<Medication>.from(result);
  sorted.sort((a, b) => _compare(a, b, query.sort));
  return sorted;
}

bool _matchesText(Medication medication, String query) {
  final haystack = _normalize(
    [
      medication.name,
      medication.activeIngredient,
      medication.strength,
      medication.form,
      medication.category,
      medication.atcCode ?? '',
      medication.authorizationNumber ?? '',
      medication.marketingAuthorizationHolder ?? '',
      medication.manufacturer ?? '',
      medication.localRepresentative ?? '',
      medication.dispensingStatus ?? '',
      medication.prescribingMode ?? '',
      medication.dispensingPlace ?? '',
      medication.marketStatus ?? '',
      medication.route ?? '',
      medication.packageDescription ?? '',
      medication.hzzoGuidelineCode ?? '',
    ].join(' '),
  );

  final tokens = query
      .split(' ')
      .where((token) => token.isNotEmpty)
      .toList(growable: false);

  return tokens.every(haystack.contains);
}

bool _matchesDispensing(
  Medication medication,
  DispensingFilter filter,
) {
  return switch (filter) {
    DispensingFilter.all => true,
    DispensingFilter.prescription =>
      medication.requiresPrescription == true,
    DispensingFilter.otc =>
      medication.requiresPrescription == false,
    DispensingFilter.unknown =>
      medication.requiresPrescription == null,
  };
}

bool _matchesReimbursement(
  Medication medication,
  ReimbursementFilter filter,
) {
  return switch (filter) {
    ReimbursementFilter.all => true,
    ReimbursementFilter.listed => medication.isOnHzzoList,
    ReimbursementFilter.basic =>
      medication.reimbursementStatus == ReimbursementStatus.basic,
    ReimbursementFilter.supplementary =>
      medication.reimbursementStatus ==
          ReimbursementStatus.supplementary,
    ReimbursementFilter.notListed => !medication.isOnHzzoList,
  };
}

bool _matchesPrice(
  Medication medication,
  PriceFilter filter,
) {
  return switch (filter) {
    PriceFilter.all => true,
    PriceFilter.anyPrice => medication.prices.isNotEmpty,
    PriceFilter.copay => medication.prices.any(
        (item) => item.kind == MedicationPriceKind.hzzoCopay,
      ),
    PriceFilter.wholesale => medication.prices.any(
        (item) => item.kind == MedicationPriceKind.maxWholesale,
      ),
  };
}

int _compare(
  Medication a,
  Medication b,
  MedicationSort sort,
) {
  final nameCompare =
      a.name.toLowerCase().compareTo(b.name.toLowerCase());

  return switch (sort) {
    MedicationSort.nameAsc => nameCompare,
    MedicationSort.ingredientAsc => _withNameFallback(
        a.activeIngredient.toLowerCase().compareTo(
              b.activeIngredient.toLowerCase(),
            ),
        nameCompare,
      ),
    MedicationSort.atcAsc => _withNameFallback(
        (a.atcCode ?? 'ZZZZZZ')
            .compareTo(b.atcCode ?? 'ZZZZZZ'),
        nameCompare,
      ),
    MedicationSort.priceAsc => _comparePrice(
        a,
        b,
        descending: false,
        fallback: nameCompare,
      ),
    MedicationSort.priceDesc => _comparePrice(
        a,
        b,
        descending: true,
        fallback: nameCompare,
      ),
  };
}

int _comparePrice(
  Medication a,
  Medication b, {
  required bool descending,
  required int fallback,
}) {
  final aPrice = _primaryPrice(a);
  final bPrice = _primaryPrice(b);

  if (aPrice == null && bPrice == null) return fallback;
  if (aPrice == null) return 1;
  if (bPrice == null) return -1;

  final compared = aPrice.compareTo(bPrice);
  if (compared == 0) return fallback;
  return descending ? -compared : compared;
}

double? _primaryPrice(Medication medication) {
  final copay = medication.hzzoCopay?.amount;
  if (copay != null) return copay;

  final wholesale = medication.maxWholesalePrice?.amount;
  if (wholesale != null) return wholesale;

  if (medication.prices.isEmpty) return null;
  return medication.prices.first.amount;
}

int _withNameFallback(int result, int fallback) {
  return result == 0 ? fallback : result;
}

String _normalize(String value) {
  var normalized = value.toLowerCase().trim();
  const replacements = {
    'č': 'c',
    'ć': 'c',
    'ž': 'z',
    'š': 's',
    'đ': 'd',
  };
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized.replaceAll(RegExp(r'\s+'), ' ');
}
