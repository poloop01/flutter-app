import 'package:uuid/uuid.dart';

class Visit {
  final String date;
  final String illness;
  final String teethIllness;
  final String whatWasDone;
  final double totalUSD;
  final double paidUSD;
  final double remainingUSD;
  final List<String> imageNames;

  Visit({
    required this.date,
    required this.illness,
    required this.teethIllness,
    required this.whatWasDone,
    required this.totalUSD,
    required this.paidUSD,
    required this.remainingUSD,
    List<String>? imageNames,
  }) : imageNames = imageNames ?? [];

  factory Visit.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
    return Visit(
      date: json['date'] ?? '',
      illness: json['illness'] ?? '',
      teethIllness: json['teethIllness'] ?? '',
      whatWasDone: json['whatWasDone'] ?? '',
      totalUSD: parse(json['totalUSD']),
      paidUSD: parse(json['paidUSD']),
      remainingUSD: parse(json['remainingUSD']),
      imageNames: List<String>.from(json['imageNames'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'illness': illness,
        'teethIllness': teethIllness,
        'whatWasDone': whatWasDone,
        'totalUSD': totalUSD,
        'paidUSD': paidUSD,
        'remainingUSD': remainingUSD,
        'imageNames': imageNames,
      };
}

class User {
  final String id;
  final String name;
  final List<Visit> visits;

  User({String? id, required this.name, this.visits = const []})
      : id = id ?? Uuid().v4();          // ← remove const

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] ?? Uuid().v4(),   // ← remove const
        name: json['name'] ?? '',
        visits: (json['visits'] as List<dynamic>?)
                ?.map((e) => Visit.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'visits': visits.map((v) => v.toJson()).toList(),
      };
}