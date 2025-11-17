import 'package:flutter/material.dart';
import 'app.dart';
import 'scr/storage/patients_storage.dart';
import '/scr/storage/appointment_storage.dart';
import '/scr/services/image_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await PatientsStorage.init();
  await AppointmentStorage.init();
  // ImageHelper.init(Storage.imgDir);
  runApp(const MyApp());
}