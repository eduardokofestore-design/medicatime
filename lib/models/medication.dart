class Medication {
  String id;
  String name;
  String dosage;
  bool isDaily;
  List<String> times; // List of time strings like "08:00"
  List<int>? days; // For weekly, list of weekday numbers (1=Monday, 7=Sunday)
  String notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.isDaily,
    required this.times,
    this.days,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'isDaily': isDaily,
      'times': times,
      'days': days,
      'notes': notes,
    };
  }

  factory Medication.fromMap(String id, Map<String, dynamic> map) {
    return Medication(
      id: id,
      name: map['name'],
      dosage: map['dosage'],
      isDaily: map['isDaily'],
      times: List<String>.from(map['times']),
      days: map['days'] != null ? List<int>.from(map['days']) : null,
      notes: map['notes'],
    );
  }
}

class MedicationHistory {
  String id;
  String medicationId;
  DateTime date;
  String time; // e.g., "08:00"
  String status; // 'taken', 'missed', 'skipped'

  MedicationHistory({
    required this.id,
    required this.medicationId,
    required this.date,
    required this.time,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicationId': medicationId,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
    };
  }

  factory MedicationHistory.fromMap(String id, Map<String, dynamic> map) {
    return MedicationHistory(
      id: id,
      medicationId: map['medicationId'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      status: map['status'],
    );
  }
}