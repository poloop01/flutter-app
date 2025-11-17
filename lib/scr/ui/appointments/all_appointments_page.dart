import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/appointment.dart';
import 'view_appointment_page.dart';

class AllAppointmentsPage extends StatefulWidget {
  final List<Appointment> appointments;
  final ValueChanged<List<Appointment>>? onChanged;

  const AllAppointmentsPage({
    super.key,
    required this.appointments,
    this.onChanged,
  });

  @override
  State<AllAppointmentsPage> createState() => _AllAppointmentsPageState();
}

class _AllAppointmentsPageState extends State<AllAppointmentsPage> {
  String search = '';

  /* --------------------------------------------------------------- */
  /* ---------------------- helpers -------------------------------- */
  /* --------------------------------------------------------------- */
  String get today => DateTime.now().toIso8601String().split('T')[0];

  bool isToday(Appointment a)    => a.date == today && !a.attended;
  bool isUpcoming(Appointment a) => a.date.compareTo(today) > 0 && !a.attended;
  bool isExpired(Appointment a)  => a.date.compareTo(today) < 0 && !a.attended;

  /* --------------------------------------------------------------- */
  /* -------------------- JSON persistence ------------------------- */
  /* --------------------------------------------------------------- */
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/appointments.json');
  }

  Future<void> saveAppointments() async {
    final file = await _localFile;
    final jsonList = widget.appointments.map((a) => a.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList), flush: true);
  }

  /* --------------------------------------------------------------- */
  /* -------------------- cool snack-bar --------------------------- */
  /* --------------------------------------------------------------- */
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

  /* --------------------------------------------------------------- */
  /* -------------------- mark single ------------------------------ */
  /* --------------------------------------------------------------- */
  void _markAttended(Appointment a) {
    final updated = a.copyWith(attended: true);
    setState(() {
      widget.appointments.remove(a);
      widget.appointments.add(updated);
    });
    widget.onChanged?.call(List.from(widget.appointments));
    saveAppointments();
    _showCoolSnackBar('${a.name} marked as attended');
  }

  /* --------------------------------------------------------------- */
  /* -------------------- mark all today --------------------------- */
  /* --------------------------------------------------------------- */
  Future<void> _attendAllToday() async {
    final toMark = widget.appointments.where(isToday).toList();
    if (toMark.isEmpty) return;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Mark ${toMark.length} today’s appointment(s) as attended?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            label: const Text('Attend All'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      for (final a in toMark) {
        widget.appointments.remove(a);
        widget.appointments.add(a.copyWith(attended: true));
      }
    });
    widget.onChanged?.call(List.from(widget.appointments));
    saveAppointments();
    _showCoolSnackBar('${toMark.length} appointment(s) attended');
  }

  /* --------------------------------------------------------------- */
  /* ---------------- delete all expired ------------------------- */
  /* --------------------------------------------------------------- */
  Future<void> _deleteAllExpired() async {
    final toDelete = widget.appointments.where(isExpired).toList();
    if (toDelete.isEmpty) return;

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Permanently delete ${toDelete.length} expired appointment(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete All'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => widget.appointments.removeWhere(isExpired));
    widget.onChanged?.call(List.from(widget.appointments));
    saveAppointments();
    _showCoolSnackBar('${toDelete.length} expired appointment(s) deleted');
  }

  /* --------------------------------------------------------------- */
  /* ---------------- single delete ------------------------------ */
  /* --------------------------------------------------------------- */
  Future<void> _deleteSingle(Appointment a) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete “${a.name}”?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => widget.appointments.remove(a));
    widget.onChanged?.call(List.from(widget.appointments));
    saveAppointments();
    _showCoolSnackBar('${a.name} deleted');
  }

  /* --------------------------------------------------------------- */
  /* -------------------- UI --------------------------------------- */
  /* --------------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    final filtered = widget.appointments.where((a) {
      final q = search.toLowerCase();
      return a.name.toLowerCase().contains(q) || a.reason.toLowerCase().contains(q);
    }).toList();

    final todayList    = filtered.where(isToday).toList();
    final upcomingList = filtered.where(isUpcoming).toList();
    final expiredList  = filtered.where(isExpired).toList();

    final todayCount    = todayList.length;
    final upcomingCount = upcomingList.length;
    final expiredCount  = expiredList.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Appointments', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPadding = isTablet ? 32.0 : 16.0;
          final vPadding = isTablet ? 24.0 : 16.0;
          final maxContentWidth = isTablet ? 700.0 : double.infinity;

          return Center(
            child: Container(
              width: maxContentWidth,
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Column(
                children: [
                  /* ---------- SEARCH BAR ---------- */
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
                      onChanged: (v) => setState(() => search = v),
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
                                Icon(Icons.calendar_today_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  widget.appointments.isEmpty
                                      ? 'No appointments scheduled'
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
                              /* ---------------- TODAY ---------------- */
                              if (todayList.isNotEmpty) ...[
                                _sectionHeader('Today ($todayCount)', Icons.today,
                                    trailing: TextButton.icon(
                                      icon: const Icon(Icons.done_all, size: 18),
                                      label: const Text('Attend All'),
                                      onPressed: _attendAllToday,
                                    )),
                                ...todayList.map(_todayCard),
                                const SizedBox(height: 12),
                              ],

                              /* ---------------- UPCOMING ------------- */
                              if (upcomingList.isNotEmpty) ...[
                                _sectionHeader('Upcoming ($upcomingCount)', Icons.upcoming),
                                ...upcomingList.map(_genericCard),
                                const SizedBox(height: 12),
                              ],

                              /* ---------------- EXPIRED -------------- */
                              if (expiredList.isNotEmpty) ...[
                                _sectionHeader('Expired ($expiredCount)', Icons.event_busy,
                                    trailing: TextButton.icon(
                                      icon: const Icon(Icons.delete_sweep, size: 18),
                                      label: const Text('Delete All'),
                                      onPressed: _deleteAllExpired,
                                    )),
                                ...expiredList.map(_expiredCard),
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
  Widget _sectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _todayCard(Appointment a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_month, color: Color(0xFF6366F1), size: 24),
        ),
        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${a.date}  ${a.startTime} –${a.endTime}'),
        trailing: ElevatedButton.icon(
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Attend'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _markAttended(a),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ViewAppointmentPage(appointment: a)),
        ),
      ),
    );
  }

  Widget _genericCard(Appointment a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_month, color: Color(0xFF6366F1), size: 24),
        ),
        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${a.date}  ${a.startTime} –${a.endTime}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ViewAppointmentPage(appointment: a)),
        ),
      ),
    );
  }

  Widget _expiredCard(Appointment a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.event_busy, color: Colors.red.shade700, size: 24),
        ),
        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${a.date}  ${a.startTime} –${a.endTime}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteSingle(a),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ViewAppointmentPage(appointment: a)),
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------- */
/* ------------------ helper extension --------------------------- */
/* --------------------------------------------------------------- */
extension _CopyWith on Appointment {
  Appointment copyWith({bool? attended}) => Appointment(
        id: id,
        name: name,
        date: date,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
        attended: attended ?? this.attended,
      );
}