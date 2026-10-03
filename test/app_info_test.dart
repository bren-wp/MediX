import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/core/app_info.dart';

void main() {
  test('app version metadata matches pubspec', () async {
    final pubspec = await File('pubspec.yaml').readAsString();

    expect(
      pubspec,
      contains('version: ${MedixAppInfo.displayVersion}'),
    );
  });
}
