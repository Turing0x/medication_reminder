import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import 'medication_form_screen.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final Medication medication;

  const MedicationDetailScreen({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextAlarmTime = _calculateNextAlarmTime(medication);
    final reminderHours = _generateReminderHours(medication);

    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MedicationFormScreen(
                    medication: medication,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(
              title: 'Dosage',
              content: medication.dosage,
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Frequency',
              content: 'Every ${medication.frequencyInHours} hours',
              icon: Icons.access_time,
            ),
            const SizedBox(height: 16),
            _buildDetailCard(
              title: 'Start Time',
              content: _formatTime(medication.startTime),
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildNextReminderCard(context, nextAlarmTime),
            const SizedBox(height: 16),
            _buildReminderHoursCard(context, reminderHours, nextAlarmTime),
            if (medication.notes != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Notes',
                content: medication.notes!,
                icon: Icons.note,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextReminderCard(BuildContext context, DateTime? nextAlarmTime) {
    final isToday = nextAlarmTime != null &&
        nextAlarmTime.year == DateTime.now().year &&
        nextAlarmTime.month == DateTime.now().month &&
        nextAlarmTime.day == DateTime.now().day;

    return Card(
      color: Theme.of(context).primaryColor.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Next Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (nextAlarmTime != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimeWithDate(nextAlarmTime),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isToday) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ] else ...[
              Text(
                'No upcoming reminders',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReminderHoursCard(
    BuildContext context,
    List<DateTime> reminderHours,
    DateTime? nextAlarmTime,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule),
                const SizedBox(width: 8),
                const Text(
                  'Reminder Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...reminderHours.map((time) {
              final isNextReminder = nextAlarmTime != null &&
                  time.year == nextAlarmTime.year &&
                  time.month == nextAlarmTime.month &&
                  time.day == nextAlarmTime.day &&
                  time.hour == nextAlarmTime.hour &&
                  time.minute == nextAlarmTime.minute;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(
                      isNextReminder ? Icons.circle : Icons.circle_outlined,
                      size: 8,
                      color: isNextReminder
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeWithDate(time),
                      style: TextStyle(
                        fontWeight: isNextReminder ? FontWeight.bold : null,
                        color: isNextReminder
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  DateTime? _calculateNextAlarmTime(Medication medication) {
    if (!medication.isActive) return null;

    final now = DateTime.now();
    var nextTime = medication.startTime;

    while (nextTime.isBefore(now)) {
      nextTime = nextTime.add(Duration(hours: medication.frequencyInHours));
    }

    return nextTime;
  }

  List<DateTime> _generateReminderHours(Medication medication) {
    if (!medication.isActive) return [];

    final List<DateTime> times = [];
    final now = DateTime.now();
    var currentTime = medication.startTime;
    final endTime = now.add(const Duration(days: 14)); // Show next 14 days

    while (currentTime.isBefore(endTime)) {
      if (currentTime.isAfter(now)) {
        times.add(currentTime);
      }
      currentTime =
          currentTime.add(Duration(hours: medication.frequencyInHours));
    }

    return times;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatTimeWithDate(DateTime time) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    String datePrefix;
    if (time.year == today.year &&
        time.month == today.month &&
        time.day == today.day) {
      datePrefix = 'Today';
    } else if (time.year == tomorrow.year &&
        time.month == tomorrow.month &&
        time.day == tomorrow.day) {
      datePrefix = 'Tomorrow';
    } else {
      datePrefix = '${time.day}/${time.month}';
    }

    return '$datePrefix at ${_formatTime(time)}';
  }
}
