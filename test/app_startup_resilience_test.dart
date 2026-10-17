import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medix/app/medix_app.dart';
import 'package:medix/features/home/app_shell.dart';
import 'package:medix/features/onboarding/onboarding_screen.dart';
import 'package:medix/features/search/search_screen.dart';
import 'package:medix/models/medication.dart';
import 'package:medix/models/therapy_entry.dart';
import 'package:medix/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/medication_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home loads before native reminder initialization completes',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'medix.onboarding_completed.v1': true,
    });
    final reminders = _PendingReminders();
    await tester.pumpWidget(
      MedixApp(
        repositoryLoader: () async => buildTestRepository(),
        remindersFactory: () => reminders,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(reminders.syncCalled, isTrue);
    // Search and its costly catalog index are deferred until tapped.
    expect(find.byType(SearchScreen), findsNothing);

    final shell = tester.widget<AppShell>(find.byType(AppShell));
    expect(shell.state.repository.medications, hasLength(4));
    final nav = tester.widget<NavigationBar>(find.byType(NavigationBar));
    nav.onDestinationSelected!(1);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    // Leaving a tab should preserve its state without rebuilding it.
    final navAgain = tester.widget<NavigationBar>(find.byType(NavigationBar));
    navAgain.onDestinationSelected!(0);
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });

  testWidgets('onboarding remains usable when reminder service is unavailable',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MedixApp(
        repositoryLoader: () async => buildTestRepository(),
        remindersFactory: () => throw StateError('unavailable'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}

class _PendingReminders implements TherapyReminderScheduler {
  final Completer<void> neverInitialized = Completer<void>();
  bool syncCalled = false;

  @override
  Future<void> initialize() => neverInitialized.future;

  @override
  Future<bool> requestPermissions() async => false;

  @override
  Future<void> syncTherapy({
    required List<TherapyEntry> therapy,
    required Medication? Function(String medicationId) medicationById,
  }) async {
    syncCalled = true;
    await initialize();
  }
}
