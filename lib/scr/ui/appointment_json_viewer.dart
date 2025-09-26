import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../storage/appointment_storage.dart';

class AppointmentJsonViewerPage extends StatelessWidget {
  const AppointmentJsonViewerPage({super.key});

  Future<String> _load() async => await AppointmentStorage.jsonFile.readAsString();

  Future<void> _copy(BuildContext context) async {
    final text = await _load();
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('JSON copied to clipboard'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Appointments JSON', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.indigo),
            tooltip: 'Copy JSON',
            onPressed: () => _copy(context),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final json = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  json,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}