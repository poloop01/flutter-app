import 'package:flutter/material.dart';
import 'json_viewer_page.dart'; // new page below

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.folder_open, color: Colors.white),
          label: const Text('Open JSON File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const JsonViewerPage()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            shadowColor: Colors.red.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
    );
  }
}