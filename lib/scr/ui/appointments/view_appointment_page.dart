import 'package:flutter/material.dart';
import '../../models/appointment.dart';

class ViewAppointmentPage extends StatelessWidget {
  final Appointment appointment;

  const ViewAppointmentPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: Text(appointment.name), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPadding = isTablet ? 32.0 : 16.0;
          final vPadding = isTablet ? 24.0 : 16.0;
          final maxContentWidth = isTablet ? 700.0 : double.infinity;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field('Patient Name', appointment.name, Icons.person),
                    const SizedBox(height: 16),

                    /* --------------- date --------------- */
                    _field('Appointment Date', appointment.date, Icons.calendar_today),
                    const SizedBox(height: 16),

                    /* --------------- phone -------------- */
                    _field(
                      'Phone',
                      appointment.phone?.isNotEmpty == true
                          ? appointment.phone!
                          : '—',
                      Icons.phone,
                    ),
                    const SizedBox(height: 16),

                    /* --------------- time slot ---------- */
                    _field(
                      'Time Slot',
                      '${appointment.startTime}  –  ${appointment.endTime}',
                      Icons.schedule,
                    ),
                    const SizedBox(height: 16),

                    /* --------------- reason ------------- */
                    _field('Reason / Notes', appointment.reason, Icons.short_text,
                        maxLines: 5),
                  ],
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
  Widget _field(String label, String value, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: TextEditingController(text: value),
      readOnly: true,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}