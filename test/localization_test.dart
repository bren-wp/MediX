import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/localization/medix_localizations.dart';

void main() {
  test('Hrvatski je jedini ponuđeni jezik i zadana lokalizacija', () {
    expect(MedixLanguages.primaryCode, 'hr');
    expect(MedixLanguages.supported.map((l) => l.code), ['hr']);
    expect(MedixLanguages.locales, [const Locale('hr')]);
    expect(MedixLanguages.normalize(null), 'hr');
    expect(MedixLanguages.normalize('en'), 'hr');
    expect(MedixLanguages.normalize('nepoznat'), 'hr');
  });

  test('Sve glavne sekcije imaju hrvatski prijevod', () {
    final loc = MedixLocalizations(const Locale('hr'));
    for (final key in const [
      'home', 'search', 'therapy', 'favorites', 'more', 'settings',
      'language', 'privacy', 'medicalDisclaimer', 'loading',
      'dataErrorTitle', 'retry', 'onboarding1Title', 'filters',
      'accessTitle', 'exportReady', 'remindersPermissionDenied',
    ]) {
      expect(loc.t(key), isNot(key), reason: key);
      expect(loc.t(key), isNotEmpty);
    }
    expect(loc.t('loading'), contains('lijek'));
    expect(loc.tArgs('results', {'count': 5}), contains('5'));
  });

  test('Nepoznata lokalizacija i dalje koristi hrvatske tekstove', () {
    final loc = MedixLocalizations(const Locale('en'));
    expect(loc.t('home'), 'Početna');
    expect(loc.t('settings'), 'Postavke');
  });
}
