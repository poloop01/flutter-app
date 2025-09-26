import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class Storage {
  static late final Directory jsonDir;
  static late final Directory imgDir;
  static late final File _file;

  static Future<void> init() async {
    final root = await getApplicationDocumentsDirectory();

    jsonDir = Directory('${root.path}/data');
    imgDir  = Directory('${root.path}/images');

    await jsonDir.create(recursive: true);
    await imgDir.create(recursive: true);

    _file = File('${jsonDir.path}/users.json');
  }

  static Future<List<User>> loadUsers() async {
    if (!await _file.exists()) return [];
    final content = await _file.readAsString();
    if (content.trim().isEmpty) return [];
    final list = jsonDecode(content) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final jsonList = users.map((u) => u.toJson()).toList();
    await _file.writeAsString(jsonEncode(jsonList));
  }
    static File get jsonFile => _file;
}