// import 'package:uuid/uuid.dart';

// /* ----------------------------------------------------------
//  *  VISIT  –  mirrors the SQL table
//  * ---------------------------------------------------------- */
// class Visit {
//   final String id;
//   final String patientId;
//   final String caseId;
//   final String date;
//   final String illness;
//   final String teethIllness;
//   final String whatWasDone;
//   final double totalUsd;
//   final double paidUsd;
//   final double remainingUsd;
//   final List<String> imageNames;
//   final String createdAt;
//   final String updatedAt;

//   Visit({
//     String? id,
//     this.patientId = '',
//     this.caseId = '',
//     this.date = '',
//     this.illness = '',
//     this.teethIllness = '',
//     this.whatWasDone = '',
//     this.totalUsd = 0.0,
//     this.paidUsd = 0.0,
//     this.remainingUsd = 0.0,
//     List<String>? imageNames,
//     this.createdAt = '',
//     this.updatedAt = '',
//   })  : id = id ?? const Uuid().v4(),
//         imageNames = imageNames ?? [];

//   factory Visit.fromJson(Map<String, dynamic> j) {
//     double _d(dynamic v) =>
//         (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
//     return Visit(
//       id: j['id'] ?? const Uuid().v4(),
//       patientId: j['patient_id'] ?? '',
//       caseId: j['case_id'] ?? '',
//       date: j['date'] ?? '',
//       illness: j['illness'] ?? '',
//       teethIllness: j['teeth_illness'] ?? '',
//       whatWasDone: j['what_was_done'] ?? '',
//       totalUsd: _d(j['total_usd']),
//       paidUsd: _d(j['paid_usd']),
//       remainingUsd: _d(j['remaining_usd']),
//       imageNames: (j['image_names'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [],
//       createdAt: j['created_at'] ?? '',
//       updatedAt: j['updated_at'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'patient_id': patientId,
//         'case_id': caseId,
//         'date': date,
//         'illness': illness,
//         'teeth_illness': teethIllness,
//         'what_was_done': whatWasDone,
//         'total_usd': totalUsd,
//         'paid_usd': paidUsd,
//         'remaining_usd': remainingUsd,
//         'image_names': imageNames,
//         'created_at': createdAt,
//         'updated_at': updatedAt,
//       };
// }

// /* ----------------------------------------------------------
//  *  CASE  –  mirrors the SQL table
//  * ---------------------------------------------------------- */
// class Case {
//   final String id;
//   final String patientId;
//   final String title;
//   final String caseDate;
//   final String status; // 'open' | 'finished'
//   final String notes;
//   final String createdAt;
//   final String updatedAt;
//   final List<Visit> visits;

//   Case({
//     String? id,
//     this.patientId = '',
//     this.title = '',
//     this.caseDate = '',
//     this.status = 'open',
//     this.notes = '',
//     this.createdAt = '',
//     this.updatedAt = '',
//     this.visits = const [],
//   }) : id = id ?? const Uuid().v4();

//   factory Case.fromJson(Map<String, dynamic> j) => Case(
//         id: j['id'] ?? const Uuid().v4(),
//         patientId: j['patient_id'] ?? '',
//         title: j['title'] ?? '',
//         caseDate: j['case_date'] ?? '',
//         status: j['status'] ?? 'open',
//         notes: j['notes'] ?? '',
//         createdAt: j['created_at'] ?? '',
//         updatedAt: j['updated_at'] ?? '',
//         visits: (j['visits'] as List<dynamic>?)
//                 ?.map((v) => Visit.fromJson(v as Map<String, dynamic>))
//                 .toList() ??
//             [],
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'patient_id': patientId,
//         'title': title,
//         'case_date': caseDate,
//         'status': status,
//         'notes': notes,
//         'created_at': createdAt,
//         'updated_at': updatedAt,
//         'visits': visits.map((v) => v.toJson()).toList(),
//       };
// }

// /* ----------------------------------------------------------
//  *  USER  –  mirrors patients table
//  * ---------------------------------------------------------- */
// class User {
//   final String id;
//   final String name;
//   final String phone;
//   final String createdAt;
//   final String updatedAt;
//   final List<Case> cases;

//   User({
//     String? id,
//     required this.name,
//     this.phone = '',
//     this.createdAt = '',
//     this.updatedAt = '',
//     this.cases = const [],
//   }) : id = id ?? const Uuid().v4();

//   factory User.fromJson(Map<String, dynamic> j) => User(
//         id: j['id'] ?? const Uuid().v4(),
//         name: j['name'] ?? '',
//         phone: j['phone'] ?? '',
//         createdAt: j['created_at'] ?? '',
//         updatedAt: j['updated_at'] ?? '',
//         cases: (j['cases'] as List<dynamic>?)
//                 ?.map((c) => Case.fromJson(c as Map<String, dynamic>))
//                 .toList() ??
//             [],
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'name': name,
//         'phone': phone,
//         'created_at': createdAt,
//         'updated_at': updatedAt,
//         'cases': cases.map((c) => c.toJson()).toList(),
//       };
// }