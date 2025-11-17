import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';

class AddAppointmentPage extends StatefulWidget {
  final Function(Appointment) onSave;
  const AddAppointmentPage({super.key, required this.onSave});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  /* ---- controllers ---- */
  final nameC = TextEditingController();
  final dateC = TextEditingController();
  final startC = TextEditingController();   // NEW
  final endC = TextEditingController();     // NEW
  final reasonC = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateC.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    nameC.dispose();
    dateC.dispose();
    startC.dispose();
    endC.dispose();
    reasonC.dispose();
    super.dispose();
  }

  /* ---------------------------------------------------- */
  /* -------------------- date picker ------------------- */
  /* ---------------------------------------------------- */
  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateC.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /* ---------------------------------------------------- */
  /* -------------------- time pickers ------------------ */
  /* ---------------------------------------------------- */
  void _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked == null) return;

    final formatted = picked.format(context); // → "4:30 PM"
    setState(() {
      if (isStart) {
        startC.text = formatted;
      } else {
        endC.text = formatted;
      }
    });
  }

  /* ---------------------------------------------------- */
  /* ---------------------- save ------------------------ */
  /* ---------------------------------------------------- */
  void _save() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSave(Appointment(
      name: nameC.text.trim(),
      date: dateC.text.trim(),
      startTime: startC.text.trim(), // NEW
      endTime: endC.text.trim(),     // NEW
      reason: reasonC.text.trim(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Appointment saved!"),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    Navigator.pop(context);
  }

  /* ---------------------------------------------------- */
  /* -------------------- build ------------------------- */
  /* ---------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPadding = isTablet ? 32.0 : 16.0;
          final vPadding = isTablet ? 24.0 : 16.0;
          final fieldSpacing = isTablet ? 20.0 : 16.0;
          final maxFieldWidth = isTablet ? 600.0 : double.infinity;

          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxFieldWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textField(nameC, 'Patient Name *', Icons.person_outline),
                      SizedBox(height: fieldSpacing),

                      /* --------------- date --------------- */
                      _textField(
                        dateC,
                        'Date *',
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: _pickDate,
                      ),
                      SizedBox(height: fieldSpacing),

                      /* --------------- time row ----------- */
                      Row(
                        children: [
                          Expanded(
                            child: _textField(
                              startC,
                              'From *',
                              Icons.schedule,
                              readOnly: true,
                              onTap: () => _pickTime(true),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _textField(
                              endC,
                              'To *',
                              Icons.schedule,
                              readOnly: true,
                              onTap: () => _pickTime(false),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: fieldSpacing),

                      /* --------------- reason ------------- */
                      _textField(
                        reasonC,
                        'Reason / Notes *',
                        Icons.notes,
                        maxLines: 4,
                      ),
                      SizedBox(height: fieldSpacing * 1.5),

                      /* --------------- save button -------- */
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Save Appointment',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color.fromARGB(255, 60, 148, 232),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /* ---------------------------------------------------- */
  /* ------------------ reusable field ------------------ */
  /* ---------------------------------------------------- */
  Widget _textField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool enabled = true,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: c,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      onTap: onTap,
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: enabled ? const Color.fromARGB(255, 3, 158, 255) : Colors.grey),
        errorStyle: const TextStyle(color: Colors.red),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}