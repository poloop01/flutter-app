import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImageHelper {
  static late Directory _dir;

  /// Initialize with the directory where images will be stored
  static void init(Directory imgDir) {
    _dir = imgDir;
  }

  /// Saves image bytes to disk and returns the generated file name.
  /// Uses patientId and visitId for stable, unique naming.
  static Future<String> save(Uint8List bytes, {
    required String patientId,
    required String visitId,
  }) async {
    // Generate a unique filename: {patientId}_{visitId}_{randomUUID}.jpg
    final name = '${patientId}_$visitId}_${Uuid().v4()}.jpg';
    final file = File(p.join(_dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return name;
  }


  static Future<void> delete(String name) async {
    final file = File(p.join(_dir.path, name));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Loads image bytes by filename, returns null if not found
  static Future<Uint8List?> load(String name) async {
    final file = File(p.join(_dir.path, name));
    return await file.exists() ? await file.readAsBytes() : null;
  }
}