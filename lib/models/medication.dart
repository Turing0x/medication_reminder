import 'package:flutter/foundation.dart';

@immutable
class Medication {
  final int? id;
  final String name;
  final String dosage;
  final int frequencyInHours;
  final DateTime startTime;
  final bool isActive;
  final String? notes;

  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequencyInHours,
    required this.startTime,
    this.isActive = true,
    this.notes,
  });

  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    int? frequencyInHours,
    DateTime? startTime,
    bool? isActive,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequencyInHours: frequencyInHours ?? this.frequencyInHours,
      startTime: startTime ?? this.startTime,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequencyInHours': frequencyInHours,
      'startTime': startTime.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'notes': notes,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequencyInHours: map['frequencyInHours'] as int,
      startTime: DateTime.parse(map['startTime'] as String),
      isActive: (map['isActive'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, frequencyInHours: $frequencyInHours, startTime: $startTime, isActive: $isActive, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage &&
        other.frequencyInHours == frequencyInHours &&
        other.startTime == startTime &&
        other.isActive == isActive &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
        id, name, dosage, frequencyInHours, startTime, isActive, notes);
  }
}
