import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medication_provider.dart';
import '../services/reminder_service.dart';
import 'medication_form_screen.dart';
import 'medication_detail_screen.dart';

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationsAsync = ref.watch(medicationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MedicationFormScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: medicationsAsync.when(
        data: (medications) {
          if (medications.isEmpty) {
            return const Center(
              child: Text('No medications added yet.'),
            );
          }

          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Dismissible(
                key: Key(medication.id.toString()),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) async {
                  await ref
                      .read(medicationNotifierProvider.notifier)
                      .deleteMedication(medication.id!);
                  await ReminderService().cancelReminder(medication.id!);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(medication.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dosage: ${medication.dosage}'),
                        Text(
                          'Every ${medication.frequencyInHours} hours',
                        ),
                        if (medication.notes != null)
                          Text('Notes: ${medication.notes}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            medication.isActive
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                          ),
                          onPressed: () async {
                            await ref
                                .read(medicationNotifierProvider.notifier)
                                .toggleMedicationStatus(medication.id!);
                            if (medication.isActive) {
                              await ReminderService()
                                  .cancelReminder(medication.id!);
                            } else {
                              await ReminderService()
                                  .scheduleMedicationReminder(medication);
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MedicationDetailScreen(
                            medication: medication,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
