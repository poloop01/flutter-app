import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/patients.dart';

class PatientsStorage {
  static late final Directory jsonDir;
  static late final Directory imgDir;
  static late final File _file;

  static Future<void> init() async {
    final root = await getApplicationDocumentsDirectory();

    jsonDir = Directory('${root.path}/data');
    imgDir  = Directory('${root.path}/images');

    await jsonDir.create(recursive: true);
    await imgDir.create(recursive: true);

    _file = File('${jsonDir.path}/patients.json');
  }

  static Future<List<Patient>> loadPatients() async {   // WAS loadUsers
    if (!await _file.exists()) return [];
    final content = await _file.readAsString();
    if (content.trim().isEmpty) return [];
    final list = jsonDecode(content) as List;
    return list.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> savePatients(List<Patient> patients) async { // WAS saveUsers
    final jsonList = patients.map((p) => p.toJson()).toList();
    await _file.writeAsString(jsonEncode(jsonList));
  }

  static File get jsonFile => _file;
}