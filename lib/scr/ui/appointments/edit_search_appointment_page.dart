import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import 'edit_appointment_page_view.dart';

class EditOnlyAppointmentPage extends StatefulWidget {
  final List<Appointment> appointments;
  final Function(int, Appointment) onUpdate;

  const EditOnlyAppointmentPage({
    super.key,
    required this.appointments,
    required this.onUpdate,
  });

  @override
  State<EditOnlyAppointmentPage> createState() =>
      _EditOnlyAppointmentPageState();
}

class _EditOnlyAppointmentPageState extends State<EditOnlyAppointmentPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.appointments.where((a) {
      final q = search.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.reason.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Appointments',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPadding = isTablet ? 32.0 : 16.0;
          final vPadding = isTablet ? 24.0 : 16.0;
          final maxContentWidth = isTablet ? 700.0 : double.infinity;

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: maxContentWidth,
              padding: EdgeInsets.symmetric(
                  horizontal: hPadding, vertical: vPadding),
              child: Column(
                children: [
                  // ---------- SEARCH FIELD ----------
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name or reason...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => search = val),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ---------- LIST ----------
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_calendar_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  widget.appointments.isEmpty
                                      ? 'No appointments found'
                                      : 'No results for "$search"',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final appt = filtered[index];
                              final realIndex =
                                  widget.appointments.indexOf(appt);

                              final date = DateTime.parse(appt.date);
                              final today = DateTime.now();
                              final startOfToday =
                                  DateTime(today.year, today.month, today.day);
                              final isPast = date.isBefore(startOfToday);
                              final isToday = date.year == today.year &&
                                  date.month == today.month &&
                                  date.day == today.day;

                              // build chips
                              final chips = <Widget>[];

                              /* ----------  ATTENDANCE CHIP  ---------- */
                              if (isPast && appt.attended) {
                                // expired + attended  ->  ONLY attended
                                chips.add(
                                  _chip('Attended', Colors.blue),
                                );
                              } else {
                                // expired + not-attended
                                if (isPast) {
                                  chips.add(
                                    _chip('Expired', Colors.red),
                                  );
                                }
                                // today / upcoming base tag
                                else if (isToday) {
                                  chips.add(
                                    _chip('Today', Colors.green),
                                  );
                                } else {
                                  chips.add(
                                    _chip('Upcoming', Colors.teal),
                                  );
                                }
                                // attendance sub-tag for all non-expired
                                chips.add(const SizedBox(width: 4));
                                chips.add(
                                  _chip(
                                    appt.attended ? 'Attended' : 'Not Attended',
                                    appt.attended ? Colors.blue : Colors.orange,
                                  ),
                                );
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.shade300,
                                          Colors.orange
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.calendar_month,
                                        color: Colors.white, size: 24),
                                  ),
                                  title: Text(appt.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  •  ${appt.reason}'),
                                      const SizedBox(height: 4),
                                      Row(children: chips),
                                    ],
                                  ),
                                  trailing: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orange),
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditAppointmentPage(
                                            appointment: appt,
                                            onSave: (updated) {
                                              widget.onUpdate(
                                                  realIndex, updated);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // helper to build a single chip
  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}