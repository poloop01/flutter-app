import 'package:flutter/material.dart';
import '../../models/appointment.dart';

class EditAppointmentPage extends StatefulWidget {
  final Appointment appointment;
  final Function(Appointment) onSave;

  const EditAppointmentPage({
    super.key,
    required this.appointment,
    required this.onSave,
  });

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  /* ---- controllers ---- */
  late TextEditingController nameC;
  late TextEditingController dateC;
  late TextEditingController phoneC; // ← NEW
  late TextEditingController startC;
  late TextEditingController endC;
  late TextEditingController reasonC;

  /* ---- attendance dropdown ---- */
  late bool _attended;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.appointment.name);
    dateC = TextEditingController(text: widget.appointment.date);
    phoneC = TextEditingController(text: widget.appointment.phone); // ← NEW
    startC = TextEditingController(text: widget.appointment.startTime);
    endC = TextEditingController(text: widget.appointment.endTime);
    reasonC = TextEditingController(text: widget.appointment.reason);
    _attended = widget.appointment.attended;
  }

  @override
  void dispose() {
    nameC.dispose();
    dateC.dispose();
    phoneC.dispose(); // ← NEW
    startC.dispose();
    endC.dispose();
    reasonC.dispose();
    super.dispose();
  }

  /* ---------- date picker ---------- */
  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(widget.appointment.date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  /* ---------- cool snack-bar ---------- */
  void _showCoolSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /* ---------- save ---------- */
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Appointment(
      id: widget.appointment.id,
      name: nameC.text.trim(),
      date: dateC.text.trim(),
      phone: phoneC.text.trim(), // ← NEW
      startTime: startC.text.trim(),
      endTime: endC.text.trim(),
      reason: reasonC.text.trim(),
      attended: _attended,
    );

    widget.onSave(updated);
    _showCoolSnackBar('Appointment updated!');
    Navigator.of(context).pop();
  }

  /* ---------- build ---------- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Appointment',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPad = isTablet ? 32.0 : 16.0;
          final vPad = isTablet ? 24.0 : 16.0;
          final maxW = isTablet ? 700.0 : double.infinity;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* ----- name (ONLY required) ----- */
                      _field(nameC, 'Patient Name *', Icons.person,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),

                      /* ----- date (optional) ----- */
                      _pickField(dateC, 'Date', Icons.calendar_today, _pickDate),
                      const SizedBox(height: 16),

                      /* ----- phone (optional) ----- */
                      _field(phoneC, 'Phone Number', Icons.phone_outlined),
                      const SizedBox(height: 16),

                      /* ----- time row (optional) ----- */
                      Row(
                        children: [
                          Expanded(
                            child: _pickField(
                                startC, 'From', Icons.schedule, () => _pickTime(true)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _pickField(
                                endC, 'To', Icons.schedule, () => _pickTime(false)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /* ----- attendance ----- */
                      DropdownButtonFormField<bool>(
                        value: _attended,
                        decoration: InputDecoration(
                          labelText: 'Attendance',
                          prefixIcon: const Icon(Icons.event_available,
                              color: Color.fromARGB(255, 201, 116, 18)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: false, child: Text('Not attended')),
                          DropdownMenuItem(value: true, child: Text('Attended')),
                        ],
                        onChanged: (v) => setState(() => _attended = v!),
                      ),
                      const SizedBox(height: 16),

                      /* ----- reason (optional) ----- */
                      _field(reasonC, 'Reason / Notes', Icons.short_text,
                          maxLines: 4),
                      const SizedBox(height: 32),

                      /* ----- save button ----- */
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color.fromARGB(255, 244, 136, 21),
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

  /* ---------- reusable field ---------- */
  Widget _field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 201, 116, 18)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  /* ---------- reusable picker field ---------- */
  Widget _pickField(
      TextEditingController c, String label, IconData icon, VoidCallback onTap) {
    return TextFormField(
      controller: c,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 201, 116, 18)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}