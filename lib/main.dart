import 'package:flutter/material.dart';
import 'app.dart';
import '/scr/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init(); // ← ONE-TIME init
  runApp(const MyApp());
}