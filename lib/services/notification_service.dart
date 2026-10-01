import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/medication.dart';
import '../models/therapy_entry.dart';

abstract interface class TherapyReminderScheduler {
  Future<void> initialize();

  Future<bool> requestPermissions();

  Future<void> syncTherapy({
    required List<TherapyEntry> therapy,
    required Medication? Function(String medicationId) medicationById,
  });
}

class MedixNotificationService implements TherapyReminderScheduler {
  static const _channelId = 'medix_therapy_reminders';
  static const _channelName = 'Podsjetnici za terapiju';
  static const _channelDescription =
      'Lokalni podsjetnici za vremena uzimanja terapije.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    timezone_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      // timezone defaults to UTC when the platform timezone cannot be mapped.
      // This should be rare on Android; initialization must not block app use.
    }

    const android =
        AndroidInitializationSettings('ic_stat_medix');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings: settings);

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();

    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;

    final notificationsAllowed =
        await android.requestNotificationsPermission();
    if (notificationsAllowed == false) {
      return false;
    }

    final canUseExact = await android.canScheduleExactNotifications();
    if (canUseExact == false) {
      await android.requestExactAlarmsPermission();
    }

    return true;
  }

  @override
  Future<void> syncTherapy({
    required List<TherapyEntry> therapy,
    required Medication? Function(String medicationId) medicationById,
  }) async {
    await initialize();

    // MediX currently owns only therapy schedules, so rebuilding pending
    // schedules avoids stale alarms when a therapy is edited or disabled.
    await _plugin.cancelAllPendingNotifications();

    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exactAllowed =
        await android?.canScheduleExactNotifications() ?? false;
    final scheduleMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (final entry in therapy.where((item) => item.isActive)) {
      final medication = medicationById(entry.medicationId);
      if (medication == null) continue;

      for (final time in entry.times) {
        final parts = time.split(':');
        if (parts.length != 2) continue;

        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null ||
            minute == null ||
            hour < 0 ||
            hour > 23 ||
            minute < 0 ||
            minute > 59) {
          continue;
        }

        final scheduled = _nextTime(hour, minute);
        final id = _stableId('${entry.id}|$time');

        await _plugin.zonedSchedule(
          id: id,
          title: 'Vrijeme za terapiju',
          body: '${medication.name} · ${entry.doseDescription}',
          scheduledDate: scheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
              icon: 'ic_stat_medix',
              category: AndroidNotificationCategory.reminder,
            ),
          ),
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'therapy:${entry.id}:${medication.id}',
        );
      }
    }
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _stableId(String value) {
    var hash = 0x811C9DC5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash;
  }
}
