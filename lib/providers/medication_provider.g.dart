// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeMedicationsHash() => r'303cc8f8ce75c8ac0476e495b702d8fc9ac9c44d';

/// See also [activeMedications].
@ProviderFor(activeMedications)
final activeMedicationsProvider =
    AutoDisposeFutureProvider<List<Medication>>.internal(
  activeMedications,
  name: r'activeMedicationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeMedicationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveMedicationsRef = AutoDisposeFutureProviderRef<List<Medication>>;
String _$medicationNotifierHash() =>
    r'fa3c2a2e9495fd80363f2f2fe36973271feb8ce0';

/// See also [MedicationNotifier].
@ProviderFor(MedicationNotifier)
final medicationNotifierProvider = AutoDisposeAsyncNotifierProvider<
    MedicationNotifier, List<Medication>>.internal(
  MedicationNotifier.new,
  name: r'medicationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$medicationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MedicationNotifier = AutoDisposeAsyncNotifier<List<Medication>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
