import 'dart:isolate';
import 'dart:ui';

import 'package:alarm/model/volume_settings.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/medication.dart';

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // Register the UI isolate's SendPort to allow for communication from the
    // background isolate.
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      isolateName,
    );

    // Initialize Alarm service
    await Alarm.init();

    // Check and request exact alarm permission
    await _checkExactAlarmPermission();

    // Listen for alarm ringing events
    Alarm.ringing.listen((alarmSet) {
      for (final alarm in alarmSet.alarms) {
        developer.log('Alarm ringing: ${alarm.id}');
      }
    });
  }

  Future<void> _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    _exactAlarmPermissionStatus = currentStatus;

    if (_exactAlarmPermissionStatus.isDenied) {
      final result = await Permission.scheduleExactAlarm.request();
      if (result.isGranted) {
      } else {
        developer.log('Exact alarm permission denied, using inexact alarms');
      }
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
      // Schedule alarm using the alarm package
      final alarmSettings = AlarmSettings(
        id: medication.id!,
        dateTime: nextDoseTime,
        assetAudioPath: 'assets/audio.mp3',
        loopAudio: true,
        vibrate: true,
        notificationSettings: NotificationSettings(
          title: 'Medication Reminder',
          body: 'Time to take ${medication.name} (${medication.dosage})',
          stopButton: 'Stop',
        ),
        volumeSettings: VolumeSettings.fade(
          volume: 0.8,
          fadeDuration: const Duration(seconds: 5),
          volumeEnforced: true,
        ),
        androidFullScreenIntent: true,
        warningNotificationOnKill: true,
      );

      await Alarm.set(alarmSettings: alarmSettings);
      developer.log('Alarm scheduled successfully for ${medication.name}');
    } on PlatformException catch (e) {
      developer.log('Error scheduling reminder: ${e.message}');
      if (e.code == 'exact_alarms_not_permitted') {
        await scheduleMedicationReminder(medication);
      } else {
        rethrow;
      }
    }
  }

  // The background
  static SendPort? uiSendPort;

  // The callback for our alarm
  @pragma('vm:entry-point')
  static Future<void> _showAlarm() async {
    developer.log('Alarm fired!');

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  Future<void> cancelReminder(int medicationId) async {
    await Alarm.stop(medicationId);
    developer.log('Cancelled reminder for medication ID: $medicationId');
  }

  Future<void> rescheduleAllReminders(List<Medication> medications) async {
    // Cancel all alarms
    await Alarm.stopAll();
    developer.log('Cancelled all reminders');

    for (final medication in medications) {
      if (medication.isActive) {
        await scheduleMedicationReminder(medication);
      }
    }
  }
}
