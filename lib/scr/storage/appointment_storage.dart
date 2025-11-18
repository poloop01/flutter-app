// lib/storage/appointment_storage.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/appointment.dart';

class AppointmentStorage {
  static late final Directory _jsonDir;
  static late final File _file;

  /* ----------------------------------------------------------
   * 1.  bootstrap – creates folder AND empty file if missing
   * ---------------------------------------------------------- */
  static Future<void> init() async {
    final root = await getExternalStorageDirectory();

    _jsonDir = Directory('${root!.path}/data');
    await _jsonDir.create(recursive: true);

    _file = File('${_jsonDir.path}/appointments.json');

    // ←  NEW  →
    if (!await _file.exists()) await _file.writeAsString('[]');
  }

  /* ----------------------------------------------------------
   * 2.  read – returns [] if file still missing / empty
   * ---------------------------------------------------------- */
  static Future<List<Appointment>> load() async {
    if (!await _file.exists()) return [];
    final content = await _file.readAsString();
    if (content.trim().isEmpty) return [];
    final list = jsonDecode(content) as List;
    return list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /* ----------------------------------------------------------
   * 3.  write
   * ---------------------------------------------------------- */
  static Future<void> save(List<Appointment> appointments) async {
    final jsonList = appointments.map((a) => a.toJson()).toList();
    await _file.writeAsString(jsonEncode(jsonList));
  }

  /* optional helper */
  static File get jsonFile => _file;
}