import 'package:flutter/material.dart';
// import '../../models/patients.dart';
import '../../models/appointment.dart';
import '../appointments/all_appointments_page.dart';

class HomePage extends StatelessWidget {
  // final List<User> users;
  final List<Appointment> appointments;

  const HomePage({
    super.key,
    // required this.users,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade100,
              Colors.teal.shade50,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContentCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    // helpers
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayCount =
        appointments.where((a) => a.date == today && !a.attended).length;
    final upcomingCount =
        appointments.where((a) => a.date.compareTo(today) > 0 && !a.attended).length;
    final attendedCount =
        appointments.where((a) => a.attended).length;
    final expiredCount =
        appointments.where((a) => !a.attended && a.date.compareTo(today) < 0).length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome Doctor',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          /* ------------- patients ------------- */
          // _buildStatRow(
          //   icon: Icons.people,
          //   label: 'Patients',
          //   // value: users.length.toString(),
          //   color: Colors.blue.shade600,
          // ),
          // const SizedBox(height: 16),

          /* ------------- appointment counts --- */
          _buildStatRow(
            icon: Icons.today,
            label: 'Today',
            value: todayCount.toString(),
            color: Colors.teal.shade600,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.upcoming,
            label: 'Upcoming',
            value: upcomingCount.toString(),
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.check_circle,
            label: 'Attended',
            value: attendedCount.toString(),
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: Icons.event_busy,
            label: 'Expired',
            value: expiredCount.toString(),
            color: Colors.red.shade600,
          ),
          const SizedBox(height: 24),

          /* ------------- action button -------- */
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AllAppointmentsPage(
              appointments: appointments,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'View Appointments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}