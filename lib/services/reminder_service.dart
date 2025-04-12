import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import '../models/medication.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _useExactAlarms = true;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        developer.log('Notification clicked: ${response.payload}');
      },
    );

    // Request notification permission for Android 13+
    if (await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false) {
      developer.log('Notification permission granted');
    }
  }

  Future<void> scheduleMedicationReminder(Medication medication) async {
    if (!medication.isActive) return;

    final now = DateTime.now();
    var nextDoseTime = medication.startTime;

    // Find the next dose time after now
    while (nextDoseTime.isBefore(now)) {
      nextDoseTime =
          nextDoseTime.add(Duration(hours: medication.frequencyInHours));
    }

    developer
        .log('Scheduling reminder for ${medication.name} at $nextDoseTime');

    try {
      await _notificationsPlugin.zonedSchedule(
        medication.id!,
        'Medication Reminder',
        'Time to take ${medication.name} (${medication.dosage})',
        tz.TZDateTime.from(nextDoseTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            enableLights: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: _useExactAlarms
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medication.id.toString(),
      );
      developer.log('Reminder scheduled successfully for ${medication.name}');
    } on PlatformException catch (e) {
      developer.log('Error scheduling reminder: ${e.message}');
      if (e.code == 'exact_alarms_not_permitted') {
        _useExactAlarms = false;
        await scheduleMedicationReminder(medication);
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelReminder(int medicationId) async {
    await _notificationsPlugin.cancel(medicationId);
    developer.log('Cancelled reminder for medication ID: $medicationId');
  }

  Future<void> rescheduleAllReminders(List<Medication> medications) async {
    await _notificationsPlugin.cancelAll();
    developer.log('Cancelled all reminders');
    for (final medication in medications) {
      if (medication.isActive) {
        await scheduleMedicationReminder(medication);
      }
    }
  }
}
