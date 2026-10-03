import 'dart:math' as math;

double calculateCkdEpi2021Creatinine({
  required double age,
  required double creatinineMgDl,
  required bool female,
}) {
  if (!age.isFinite || age < 18 || age > 130) {
    throw const FormatException(
      'CKD-EPI 2021 kreatininska jednadžba u MediX-u namijenjena je odraslima od 18 godina.',
    );
  }
  if (!creatinineMgDl.isFinite || creatinineMgDl <= 0) {
    throw const FormatException(
      'Unesite valjanu vrijednost serumskog kreatinina.',
    );
  }

  final kappa = female ? 0.7 : 0.9;
  final alpha = female ? -0.241 : -0.302;
  final ratio = creatinineMgDl / kappa;

  var egfr = 142 *
      math.pow(math.min(ratio, 1), alpha) *
      math.pow(math.max(ratio, 1), -1.200) *
      math.pow(0.9938, age);

  if (female) {
    egfr *= 1.012;
  }
  return egfr.toDouble();
}

double calculateOriginalMeld({
  required double bilirubinMgDl,
  required double inr,
  required double creatinineMgDl,
  required bool dialysisAtLeastTwiceLastWeek,
}) {
  if (!bilirubinMgDl.isFinite || bilirubinMgDl <= 0) {
    throw const FormatException(
      'Unesite valjanu vrijednost bilirubina.',
    );
  }
  if (!inr.isFinite || inr <= 0) {
    throw const FormatException('Unesite valjanu INR vrijednost.');
  }
  if (!creatinineMgDl.isFinite || creatinineMgDl <= 0) {
    throw const FormatException(
      'Unesite valjanu vrijednost kreatinina.',
    );
  }

  final bilirubin = math.max(1.0, bilirubinMgDl).toDouble();
  final normalizedInr = math.max(1.0, inr).toDouble();
  final creatinine = dialysisAtLeastTwiceLastWeek
      ? 4.0
      : math.min(
          4.0,
          math.max(1.0, creatinineMgDl),
        ).toDouble();

  final raw = 3.78 * math.log(bilirubin) +
      11.2 * math.log(normalizedInr) +
      9.57 * math.log(creatinine) +
      6.43;

  return raw.clamp(6.0, 40.0).toDouble();
}
