import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../services/reminder_service.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({
    super.key,
    this.medication,
  });

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  int _frequencyInHours = 24;
  TimeOfDay _startTime = TimeOfDay.now();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _frequencyInHours = widget.medication!.frequencyInHours;
      _startTime = TimeOfDay.fromDateTime(widget.medication!.startTime);
      _isActive = widget.medication!.isActive;
      if (widget.medication!.notes != null) {
        _notesController.text = widget.medication!.notes!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final startTime = DateTime(
        now.year,
        now.month,
        now.day,
        _startTime.hour,
        _startTime.minute,
      );

      final medication = Medication(
        id: widget.medication?.id,
        name: _nameController.text,
        dosage: _dosageController.text,
        frequencyInHours: _frequencyInHours,
        startTime: startTime,
        isActive: _isActive,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.medication == null) {
        // Create new medication
        await ref
            .read(medicationNotifierProvider.notifier)
            .addMedication(medication);

        final medications = await ref.read(medicationNotifierProvider.future);
        final newMedication = medications.lastWhere((m) =>
            m.name == medication.name &&
            m.dosage == medication.dosage &&
            m.frequencyInHours == medication.frequencyInHours);

        await ReminderService().scheduleMedicationReminder(newMedication);
      } else {
        // Update existing medication
        await ref
            .read(medicationNotifierProvider.notifier)
            .updateMedication(medication);

        if (medication.isActive) {
          await ReminderService().scheduleMedicationReminder(medication);
        } else {
          await ReminderService().cancelReminder(medication.id!);
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Frequency'),
                subtitle: Text('Every $_frequencyInHours hours'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (_frequencyInHours > 1) {
                            _frequencyInHours--;
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _frequencyInHours++;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime.format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMedication,
                child: Text(widget.medication == null
                    ? 'Save Medication'
                    : 'Update Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
