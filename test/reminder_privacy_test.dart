import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:medix/services/notification_service.dart';

void main() {
  test('podsjetnici ne otkrivaju naziv lijeka ili dozu', () {
    expect(MedixNotificationService.reminderTitle, 'Vrijeme za terapiju');
    expect(
      MedixNotificationService.reminderBody,
      'Otvorite MediX za pojedinosti terapije.',
    );
    for (final privateValue in ['Paracetamol', '500 mg', '2 tablete']) {
      expect(
        MedixNotificationService.reminderBody,
        isNot(contains(privateValue)),
      );
    }
  });

  test('Android obavijesti skrivaju osjetljiv sadržaj zaključanog zaslona', () {
    final source =
        File('lib/services/notification_service.dart').readAsStringSync();
    expect(source, contains('title: reminderTitle,'));
    expect(source, contains('body: reminderBody,'));
    expect(source, contains('visibility: NotificationVisibility.private,'));
    expect(source, isNot(contains("body: '\u0024{medication.name}")));
  });
}
