class Visit {
  final String date;
  final String illness;
  final String teethIllness;
  final String whatWasDone;        // NEW - stores the action performed
  final double totalUSD;
  final double paidUSD;
  final double remainingUSD;

  const Visit({
    required this.date,
    required this.illness,
    required this.teethIllness,
    required this.whatWasDone,     // NEW - must be supplied
    required this.totalUSD,
    required this.paidUSD,
    required this.remainingUSD,
  });

  /* ----------  JSON  ---------- */
  factory Visit.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

    return Visit(
      date: json['date'] ?? '',
      illness: json['illness'] ?? '',
      teethIllness: json['teethIllness'] ?? '',
      whatWasDone: json['whatWasDone'] ?? '', // NEW - load from disk
      totalUSD: parse(json['totalUSD']),
      paidUSD: parse(json['paidUSD']),
      remainingUSD: parse(json['remainingUSD']),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'illness': illness,
        'teethIllness': teethIllness,
        'whatWasDone': whatWasDone, // NEW - save to disk
        'totalUSD': totalUSD,
        'paidUSD': paidUSD,
        'remainingUSD': remainingUSD,
      };
}

class User {
  final String name;
  final List<Visit> visits;

  const User({required this.name, this.visits = const []});

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json['name'] ?? '',
        visits: (json['visits'] as List<dynamic>?)
                ?.map((e) => Visit.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'visits': visits.map((v) => v.toJson()).toList(),
      };
}