import 'package:uuid/uuid.dart';

class Appointment {
  final String id;
  final String name;
  final String date; 
  final String startTime;
  final String endTime; 
  final String reason;
  final bool attended; 

  Appointment({
    String? id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
    this.attended = false, // NEW
  }) : id = id ?? const Uuid().v4();

  /* ---------- JSON ---------- */
  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] ?? const Uuid().v4(),
        name: json['name'] ?? '',
        date: json['date'] ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        reason: json['reason'] ?? '',
        attended: json['attended'] ?? false, // NEW
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'reason': reason,
        'attended': attended,
      };
}