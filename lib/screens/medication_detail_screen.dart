import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../services/reminder_service.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final Medication medication;

  const MedicationDetailScreen({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implement edit functionality
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
            if (medication.notes != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Notes',
                content: medication.notes!,
                icon: Icons.note,
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref
                      .read(medicationNotifierProvider.notifier)
                      .toggleMedicationStatus(medication.id!);
                  if (medication.isActive) {
                    await ReminderService().cancelReminder(medication.id!);
                  } else {
                    await ReminderService()
                        .scheduleMedicationReminder(medication);
                  }
                },
                icon: Icon(
                  medication.isActive
                      ? Icons.notifications_off
                      : Icons.notifications_active,
                ),
                label: Text(
                  medication.isActive
                      ? 'Disable Reminders'
                      : 'Enable Reminders',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: medication.isActive
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
