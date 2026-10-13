import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android shares only the dedicated export cache directory', () {
    final filePaths =
        File('android/app/src/main/res/xml/file_paths.xml').readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/com/brendigo/medix/MainActivity.kt',
    ).readAsStringSync();

    expect(filePaths, contains('path="medix-exports/"'));
    expect(filePaths, isNot(contains('path="."')));
    expect(activity, contains('File(cacheDir, "medix-exports").canonicalFile'));
    expect(activity, contains('file.parentFile != exportDirectory'));
    expect(activity, contains('file.name.endsWith(".zip")'));
    expect(activity, contains('Intent.FLAG_GRANT_READ_URI_PERMISSION'));
  });

  test('export file retention and URI access remain restricted', () {
    final source =
        File('lib/services/medix_export_service.dart').readAsStringSync();
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(source, contains("medix-exports"));
    expect(source, contains('Duration(hours: 24)'));
    expect(manifest, contains('android:grantUriPermissions="true"'));
    expect(manifest, contains('android:exported="false"'));
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
  });
}
