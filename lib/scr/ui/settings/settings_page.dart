import 'package:flutter/material.dart';
import '../patients/patients_json_viewer.dart';
import '../appointments/appointment_json_viewer.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Background container
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.grey.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _jsonBtn(
                  context,
                  'Open Patients JSON',  // Changed from 'Users' to 'Patients'
                  Colors.blue,
                  const PatientsJsonViewerPage(),  // Use hardcoded patients viewer
                ),
                const SizedBox(height: 20),
                _jsonBtn(
                  context,
                  'Open Appointments JSON',
                  Colors.green,  // Different color for distinction
                  const AppointmentJsonViewerPage(),  // Use hardcoded appointments viewer
                ),
              ],
            ),
          ),
          // Footer with "Developed by" text
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: 50,
              color: const Color.fromARGB(255, 192, 141, 21),
              child: const Center(
                child: Text(
                  'Developed by Genius',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jsonBtn(BuildContext context, String text, Color color, Widget page) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.folder_open, color: Colors.white),
      label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    );
  }
}