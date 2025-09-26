import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImageHelper {
  static late Directory _dir;

  static void init(Directory imgDir) => _dir = imgDir;

  /// saves bytes → returns file name only
  static Future<String> save(Uint8List bytes,
      {required String userId, required int visitIndex}) async {
    final name = '${userId}_v${visitIndex}_${const Uuid().v4()}.jpg';
    final file = File(p.join(_dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return name;
  }

  static Future<void> delete(String name) async {
    final f = File(p.join(_dir.path, name));
    if (await f.exists()) await f.delete();
  }

  static Future<Uint8List?> load(String name) async {
    final f = File(p.join(_dir.path, name));
    return await f.exists() ? f.readAsBytes() : null;
  }
}