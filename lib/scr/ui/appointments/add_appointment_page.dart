import 'package:flutter/material.dart';
import '../../models/appointment.dart';

class AddAppointmentPage extends StatefulWidget {
  final Function(Appointment) onSave;
  const AddAppointmentPage({super.key, required this.onSave});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  final nameC   = TextEditingController();
  final dateC   = TextEditingController();
  final phoneC  = TextEditingController();
  final startC  = TextEditingController();
  final endC    = TextEditingController();
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
    phoneC.dispose();
    startC.dispose();
    endC.dispose();
    reasonC.dispose();
    super.dispose();
  }

  /* ---------- date picker ---------- */
  Future<void> _pickDate() async {
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

  /* ---------- time pickers ---------- */
  Future<void> _pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (_, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked == null) return;
    final formatted = picked.format(context);
    setState(() => isStart ? startC.text = formatted : endC.text = formatted);
  }

  /* ---------- save ---------- */
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    widget.onSave(Appointment(
      name: nameC.text.trim(),
      date: dateC.text.trim(),
      startTime: startC.text.trim(),
      endTime: endC.text.trim(),
      reason: reasonC.text.trim(),
      phone: phoneC.text.trim(), // ← NEW
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
        title: const Text('Add Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (_, c) {
          final isTablet = c.maxWidth >= 600;
          final hp = isTablet ? 32.0 : 16.0;
          final vp = isTablet ? 24.0 : 16.0;
          final fs = isTablet ? 20.0 : 16.0;
          final maxW = isTablet ? 600.0 : double.infinity;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* ----- patient name (keyboard allowed) ----- */
                      TextFormField(
                        controller: nameC,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name *',
                          prefixIcon:
                              Icon(Icons.person_outline, color: Color.fromARGB(255, 3, 158, 255)),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: fs),

                      /* ----- date (picker) ----- */
                      _pickField(dateC, 'Date', Icons.calendar_today, _pickDate),
                      SizedBox(height: fs),

                      /* ----- phone (keyboard, optional) ----- */
                      _textField(phoneC, 'Phone Number', Icons.phone_outlined),
                      SizedBox(height: fs),

                      /* ----- time row (pickers) ----- */
                      Row(
                        children: [
                          Expanded(
                              child: _pickField(startC, 'From', Icons.schedule,
                                  () => _pickTime(true))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _pickField(endC, 'To', Icons.schedule,
                                  () => _pickTime(false))),
                        ],
                      ),
                      SizedBox(height: fs),

                      /* ----- reason (keyboard allowed) ----- */
                      _textField(reasonC, 'Reason / Notes', Icons.notes,
                          maxLines: 4),
                      SizedBox(height: fs * 1.5),

                      /* ----- save button ----- */
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Appointment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 60, 148, 232),
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

  /* ---------- editable field (keyboard) ---------- */
  Widget _textField(
    TextEditingController c,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 3, 158, 255)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /* ---------- read-only picker field ---------- */
  Widget _pickField(
    TextEditingController c,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return TextFormField(
      controller: c,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 3, 158, 255)),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}