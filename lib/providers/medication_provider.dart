import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/medication.dart';
import '../services/database_service.dart';

part 'medication_provider.g.dart';

@riverpod
class MedicationNotifier extends _$MedicationNotifier {
  @override
  Future<List<Medication>> build() async {
    return await DatabaseService.instance.getAllMedications();
  }

  Future<void> addMedication(Medication medication) async {
    final id = await DatabaseService.instance.insertMedication(medication);
    final newMedication = medication.copyWith(id: id);
    state = AsyncValue.data([...state.value ?? [], newMedication]);
  }

  Future<void> updateMedication(Medication medication) async {
    await DatabaseService.instance.updateMedication(medication);
    state = AsyncValue.data([
      for (final med in state.value ?? [])
        med.id == medication.id ? medication : med
    ]);
  }

  Future<void> deleteMedication(int id) async {
    await DatabaseService.instance.deleteMedication(id);
    state = AsyncValue.data(
        [...?state.value?.where((medication) => medication.id != id)]);
  }

  Future<void> toggleMedicationStatus(int id) async {
    final medications = state.value ?? [];
    final medication = medications.firstWhere((med) => med.id == id);
    final updatedMedication =
        medication.copyWith(isActive: !medication.isActive);
    await updateMedication(updatedMedication);
  }
}

@riverpod
Future<List<Medication>> activeMedications(Ref ref) async {
  return await DatabaseService.instance.getActiveMedications();
}
