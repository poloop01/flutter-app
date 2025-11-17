import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import 'view_appointment_page.dart';

class DeleteOnlyAppointmentPage extends StatefulWidget {
  final List<Appointment> appointments;
  final ValueChanged<List<Appointment>> onChanged;

  const DeleteOnlyAppointmentPage({
    super.key,
    required this.appointments,
    required this.onChanged,
  });

  @override
  State<DeleteOnlyAppointmentPage> createState() =>
      _DeleteOnlyAppointmentPageState();
}

class _DeleteOnlyAppointmentPageState extends State<DeleteOnlyAppointmentPage> {
  String search = '';

  /* -------------- helpers -------------- */
  String get today => DateTime.now().toIso8601String().split('T')[0];
  bool isAttended(Appointment a) => a.attended;
  bool isExpired(Appointment a) =>
      !a.attended && a.date.compareTo(today) < 0;
  bool isNotAttended(Appointment a) =>
      !a.attended && a.date.compareTo(today) >= 0;

  /* -------------- confirmation dialog -------------- */
  Future<bool?> _confirm(String title, String content) async =>
      showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  /* -------------- cool snack-bar -------------- */
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

  /* -------------- bulk delete -------------- */
  Future<void> _deleteAllAttended() async {
    final toDelete = widget.appointments.where(isAttended).length;
    if (toDelete == 0) return;

    final bool? ok = await _confirm(
      'Confirm Delete All',
      'Permanently delete $toDelete attended appointment(s)?',
    );
    if (ok != true) return;

    setState(() => widget.appointments.removeWhere(isAttended));
    _notifyParent();
    _showCoolSnackBar('$toDelete attended appointment(s) deleted');
  }

  Future<void> _deleteAllExpired() async {
    final toDelete = widget.appointments.where(isExpired).length;
    if (toDelete == 0) return;

    final bool? ok = await _confirm(
      'Confirm Delete All',
      'Permanently delete $toDelete expired appointment(s)?',
    );
    if (ok != true) return;

    setState(() => widget.appointments.removeWhere(isExpired));
    _notifyParent();
    _showCoolSnackBar('$toDelete expired appointment(s) deleted');
  }

  Future<void> _deleteAllNotAttended() async {
    final toDelete = widget.appointments.where(isNotAttended).length;
    if (toDelete == 0) return;

    final bool? ok = await _confirm(
      'Confirm Delete All',
      'Permanently delete $toDelete not-attended appointment(s)?',
    );
    if (ok != true) return;

    setState(() => widget.appointments.removeWhere(isNotAttended));
    _notifyParent();
    _showCoolSnackBar('$toDelete not-attended appointment(s) deleted');
  }

  /* -------------- single delete -------------- */
  Future<void> _deleteSingle(Appointment appt) async {
    final bool? ok = await _confirm(
      'Delete Appointment',
      'Delete appointment for ${appt.name}?',
    );
    if (ok != true) return;

    setState(() => widget.appointments.remove(appt));
    _notifyParent();
    _showCoolSnackBar('${appt.name} deleted');
  }

  /* -------------- report new list -------------- */
  void _notifyParent() => widget.onChanged(List.from(widget.appointments));

  /* -------------- build -------------- */
  @override
  Widget build(BuildContext context) {
    final filtered = widget.appointments.where((a) {
      final q = search.toLowerCase();
      return a.name.toLowerCase().contains(q) || a.reason.toLowerCase().contains(q);
    }).toList();

    final attendedList = filtered.where(isAttended).toList();
    final expiredList = filtered.where(isExpired).toList();
    final notAttendedList = filtered.where(isNotAttended).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Delete Appointments',
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
                  /* ---------- SEARCH FIELD ---------- */
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

                  /* ---------- LIST ---------- */
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outlined,
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
                        : ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              /* --------------- ATTENDED --------------- */
                              if (attendedList.isNotEmpty) ...[
                                _sectionHeader(
                                  'Attended (${attendedList.length})',
                                  Icons.check_circle,
                                  onDeleteAll: _deleteAllAttended,
                                ),
                                ...attendedList.map((a) => _card(a, _deleteSingle)),
                                const SizedBox(height: 12),
                              ],

                              /* --------------- NOT ATTENDED --------------- */
                              if (notAttendedList.isNotEmpty) ...[
                                _sectionHeader(
                                  'Not Attended (${notAttendedList.length})',
                                  Icons.event_note,
                                  onDeleteAll: _deleteAllNotAttended,
                                ),
                                ...notAttendedList.map((a) => _card(a, _deleteSingle)),
                                const SizedBox(height: 12),
                              ],

                              /* --------------- EXPIRED ---------------- */
                              if (expiredList.isNotEmpty) ...[
                                _sectionHeader(
                                  'Expired (${expiredList.length})',
                                  Icons.event_busy,
                                  onDeleteAll: _deleteAllExpired,
                                ),
                                ...expiredList.map((a) => _card(a, _deleteSingle)),
                              ],
                            ],
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

  /* --------------------------------------------------------------- */
  /* -------------------- widgets ---------------------------------- */
  /* --------------------------------------------------------------- */
  Widget _sectionHeader(String title, IconData icon,
      {required VoidCallback onDeleteAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.delete_sweep, size: 18),
            label: const Text('Delete All'),
            onPressed: onDeleteAll,
          ),
        ],
      ),
    );
  }

  Widget _card(Appointment appt, void Function(Appointment) onTapDelete) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewAppointmentPage(appointment: appt),
          ),
        );
      },
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: Colors.red.shade700, size: 24),
      ),
      title: Text(appt.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${appt.date}  •  ${appt.reason}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteSingle(appt),
      ),
    ),
  );
}
}