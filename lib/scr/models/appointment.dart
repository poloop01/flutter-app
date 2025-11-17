import 'package:uuid/uuid.dart';

class Appointment {
  final String id;
  final String name;
  final String date;
  final String startTime;
  final String endTime;
  final String reason;
  final bool attended;
  final String phone;

  Appointment({
    String? id,
    required this.name,
    this.date = '',
    this.startTime = '',
    this.endTime = '',
    this.reason = '',
    this.attended = false,
    this.phone = '',
  }) : id = id ?? const Uuid().v4();

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] ?? const Uuid().v4(),
        name: json['name'] ?? '',
        date: json['date'] ?? '',
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '',
        reason: json['reason'] ?? '',
        attended: json['attended'] ?? false,
        phone: json['phone'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'reason': reason,
        'attended': attended,
        'phone': phone,
      };
}