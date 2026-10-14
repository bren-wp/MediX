import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';

void main() {
  test('English is primary and more than 20 languages are supported', () {
    expect(MedixLanguages.primaryCode, 'en');
    expect(MedixLanguages.supported.length, greaterThan(20));
    expect(MedixLanguages.isSupported('hr'), isTrue);
  });

  test('notification feedback has English fallback and Croatian translation', () {
    final english = MedixLocalizations(const Locale('en'));
    final croatian = MedixLocalizations(const Locale('hr'));
    final german = MedixLocalizations(const Locale('de'));

    for (final key in const ['remindersEnabled', 'remindersPermissionDenied']) {
      expect(english.t(key), isNot(key));
      expect(croatian.t(key), isNot(key));
      expect(german.t(key), english.t(key));
    }
  });

  test('every supported locale resolves primary navigation text', () {
    for (final language in MedixLanguages.supported) {
      final localization = MedixLocalizations(Locale(language.code));
      for (final key in const ['home', 'search', 'therapy', 'favorites', 'more', 'settings']) {
        expect(localization.t(key), isNotEmpty);
        expect(localization.t(key), isNot(key));
      }
    }
  });
}
