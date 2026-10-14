import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/app_info.dart';

void main() {
  test('MediX legal links point to published app-specific documents', () {
    expect(
      MedixAppInfo.privacyPolicyUrl,
      contains('/MediX/blob/main/docs/PRIVACY_POLICY.md'),
    );
    expect(
      MedixAppInfo.termsOfUseUrl,
      contains('/MediX/blob/main/docs/TERMS_OF_USE.md'),
    );
    final policy = File('docs/PRIVACY_POLICY.md').readAsStringSync();
    final terms = File('docs/TERMS_OF_USE.md').readAsStringSync();
    expect(policy, contains('SharedPreferences'));
    expect(policy, contains('therapy'));
    expect(terms, contains('not a medical device'));
  });

  test('app version metadata matches pubspec', () async {
    final pubspec = await File('pubspec.yaml').readAsString();

    expect(
      pubspec,
      contains('version: ${MedixAppInfo.displayVersion}'),
    );
  });
}
