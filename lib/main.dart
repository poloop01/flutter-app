import 'package:flutter/material.dart';
import 'app.dart';
import '/scr/storage/storage.dart';
import '/scr/storage/appointment_storage.dart';
import '/scr/services/image_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  await AppointmentStorage.init();
  ImageHelper.init(Storage.imgDir);
  runApp(const MyApp());
}