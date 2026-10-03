import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/clinical_calculations.dart';

void main() {
  group('CKD-EPI 2021 creatinine', () {
    test('calculates adult male eGFR', () {
      final result = calculateCkdEpi2021Creatinine(
        age: 50,
        creatinineMgDl: 1,
        female: false,
      );

      expect(result, closeTo(91.7, 0.2));
    });

    test('calculates adult female eGFR', () {
      final result = calculateCkdEpi2021Creatinine(
        age: 50,
        creatinineMgDl: 1,
        female: true,
      );

      expect(result, closeTo(68.6, 0.2));
    });

    test('rejects pediatric age', () {
      expect(
        () => calculateCkdEpi2021Creatinine(
          age: 17,
          creatinineMgDl: 1,
          female: false,
        ),
        throwsFormatException,
      );
    });
  });

  group('Original MELD', () {
    test('clamps minimum to 6', () {
      final result = calculateOriginalMeld(
        bilirubinMgDl: 1,
        inr: 1,
        creatinineMgDl: 1,
        dialysisAtLeastTwiceLastWeek: false,
      );

      expect(result, 6);
    });

    test('caps score at 40', () {
      final result = calculateOriginalMeld(
        bilirubinMgDl: 40,
        inr: 10,
        creatinineMgDl: 10,
        dialysisAtLeastTwiceLastWeek: false,
      );

      expect(result, 40);
    });

    test('uses creatinine 4 for qualifying dialysis', () {
      final dialysis = calculateOriginalMeld(
        bilirubinMgDl: 2,
        inr: 2,
        creatinineMgDl: 1,
        dialysisAtLeastTwiceLastWeek: true,
      );
      final creatinineFour = calculateOriginalMeld(
        bilirubinMgDl: 2,
        inr: 2,
        creatinineMgDl: 4,
        dialysisAtLeastTwiceLastWeek: false,
      );

      expect(dialysis, closeTo(creatinineFour, 0.0001));
    });
  });
}
