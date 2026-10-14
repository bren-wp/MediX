import 'package:flutter_test/flutter_test.dart';
import 'package:medix/data/official_price_validation.dart';

void main() {
  test('accepts finite nonnegative euro values, including decimal commas',
      () {
    expect(OfficialPriceValidation.euro(0), 0);
    expect(OfficialPriceValidation.euro(12.75), 12.75);
    expect(OfficialPriceValidation.euro(' 12,75 '), 12.75);
    expect(OfficialPriceValidation.euro('9.25'), 9.25);
  });

  test('rejects missing, invalid, negative, infinite and non-numeric prices',
      () {
    final inputs = [
      null,
      true,
      false,
      '',
      'not available',
      '-3,12',
      -3.12,
      double.nan,
      double.infinity,
      double.negativeInfinity,
      'NaN',
      'Infinity',
    ];
    for (final input in inputs) {
      expect(OfficialPriceValidation.euro(input), isNull,
          reason: 'Invalid price must not be shown: $input');
    }
  });

  test('never invents a wholesale publication date', () {
    expect(OfficialPriceValidation.publishedDate('2026-06-18'),
        '2026-06-18');
    for (final unknown in [
      null,
      '',
      'undated',
      '2026-02-30',
      '2026-13-01',
      '2026-6-18',
      '2026-10-01T00:00:00Z',
    ]) {
      expect(OfficialPriceValidation.publishedDate(unknown),
          'Datum objave nije potvrđen');
    }
  });
}
