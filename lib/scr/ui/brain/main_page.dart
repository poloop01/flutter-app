import 'package:flutter/material.dart';
import '../../storage/patients_storage.dart';
import '../../storage/appointment_storage.dart';
import '../../models/patients.dart';
import '../../models/appointment.dart';
import '../patients/patient_modal.dart';
import '../cases/cases_page.dart';

/*  -------------  appointment screens  -------------  */
import '../appointments/appointment_page.dart';
import '../appointments/add_appointment_page.dart';
import '../appointments/all_appointments_page.dart';
import '../appointments/edit_appointment_page_view.dart';
import '../appointments/edit_search_appointment_page.dart';
import '../appointments/delete_appointment_page.dart';

/*  -------------  home / settings  -------------  */
import '../home/home_page.dart';
import '../settings/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  List<Patient> patients = [];
  List<Appointment> appointments = [];
  String _searchQuery = '';

  /* =========================================================
   *                      L I F E – C Y C L E
   * =======================================================*/

  /* =========================================================
   *                      L I F E – C Y C L E
   * =======================================================*/
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    patients     = await PatientsStorage.loadPatients();
    appointments = await AppointmentStorage.load();
    if (mounted) setState(() {});
  }

  Future<void> _savePatients() async =>
      PatientsStorage.savePatients(patients);

  /* =========================================================
   *                    A P P O I N T M E N T   C R U D
   * =======================================================*/
  Future<void> _addAppointment(Appointment a) async {
    appointments.add(a);
    await AppointmentStorage.save(appointments);
    setState(() {});
  }

  Future<void> _updateAppointment(int i, Appointment a) async {
    appointments[i] = a;
    await AppointmentStorage.save(appointments);
    setState(() {});
  }

  Future<void> _deleteAppointment(int i) async {
    appointments.removeAt(i);
    await AppointmentStorage.save(appointments);
    setState(() {});
  }

  /* =========================================================
   *                      P A T I E N T   C R U D
   * =======================================================*/
  Future<void> _addPatient(String name, String phone) async {
    patients.add(Patient(name: name, phone: phone));
    await _savePatients();
    setState(() {});
  }

Future<void> _updatePatient(Patient oldPatient, String name, String phone) async {
  final index = patients.indexWhere((e) => e.id == oldPatient.id);
  if (index != -1) {
    patients[index] = oldPatient.copyWith(name: name, phone: phone);
    await _savePatients();
    setState(() {});
  }
}

  Future<void> _deletePatient(Patient p) async {
    patients.removeWhere((e) => e.id == p.id);
    await _savePatients();
    setState(() {});
  }

  /* ---------------------------------------------------------
   *              S H O W   A D D   P A T I E N T
   * -------------------------------------------------------*/
  Future<void> _showAddPatientModal() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const AddPatientDialog(),
    );
    if (result == null) return;
    await _addPatient(result.$1, result.$2);
  }

  /* ---------------------------------------------------------
   *              S H O W   E D I T   P A T I E N T
   * -------------------------------------------------------*/
  Future<void> _showEditPatientModal(Patient patient) async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => EditPatientDialog(patient: patient),
    );
    if (result == null) return;
    await _updatePatient(patient, result.$1, result.$2);
  }

  /* =========================================================
   *                        N A V I G A T I O N
   * =======================================================*/
  void _goAddAppointment() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AddAppointmentPage(onSave: _addAppointment)),
      );

  void _goSearchAppointment() => Navigator.of(context).push<List<Appointment>>(
        MaterialPageRoute(
          builder: (_) => AllAppointmentsPage(
            appointments: appointments,
            onChanged: (updated) async {
              appointments = updated;
              await AppointmentStorage.save(appointments);
              setState(() {});
            },
          ),
        ),
      );

  void _goEditAppointment() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditOnlyAppointmentPage(
            appointments: appointments,
            onUpdate: _updateAppointment,
          ),
        ),
      );

  void _goDeleteAppointment() => Navigator.of(context).push<List<Appointment>>(
        MaterialPageRoute(
          builder: (_) => DeleteOnlyAppointmentPage(
            appointments: appointments,
            onChanged: (updated) async {
              appointments = updated;
              await AppointmentStorage.save(appointments);
              setState(() {});
            },
          ),
        ),
      );

  /* =========================================================
   *                          B U I L D
   * =======================================================*/
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(appointments: appointments),
      AppointmentPage(
        onAdd:    _goAddAppointment,
        onSearch: _goSearchAppointment,
        onEdit:   _goEditAppointment,
        onDelete: _goDeleteAppointment,
      ),
      _patientsTab(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Appointments'),
          NavigationDestination(icon: Icon(Icons.supervised_user_circle), label: 'Patients'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  /* ---------------------------------------------------------
   *              P A T I E N T S   T A B   U I
   * -------------------------------------------------------*/
  Widget _patientsTab() {
    final filteredPatients = patients.where((p) {
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.phone.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPatientModal,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Patient'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          // Patients list
          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          patients.isEmpty ? 'No patients yet' : 'No results for "$_searchQuery"',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          patients.isEmpty ? 'Tap the + button to add your first patient' : 'Try a different search',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPatients.length,
                    itemBuilder: (_, i) {
                      final p = filteredPatients[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      p.phone.isEmpty ? 'No phone' : p.phone,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CasesPage(
                            patient: p,
                            onPatientUpdated: (updatedPatient) {
                              setState(() {
                                final index = patients.indexWhere((pat) => pat.id == updatedPatient.id);
                                if (index != -1) {
                                  patients[index] = updatedPatient;
                                }
                              });
                              _savePatients();
                            },
                          ),
                        ),
                      );
                    },
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'view') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CasesPage(
                                patient: p,
                                onPatientUpdated: (updatedPatient) {
                                  setState(() {
                                    final index = patients.indexWhere((pat) => pat.id == updatedPatient.id);
                                    if (index != -1) {
                                      patients[index] = updatedPatient;
                                    }
                                  });
                                  _savePatients();
                                },
                              ),
                            ),
                          );
                        } else if (value == 'edit') {
                          _showEditPatientModal(p);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(p);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('View Cases'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------------------------------------------------
   *           S H O W   P A T I E N T   D E T A I L S
   * -------------------------------------------------------*/
  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Patient Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${patient.name}'),
            const SizedBox(height: 12),
            Text('Phone: ${patient.phone.isEmpty ? "N/A" : patient.phone}'),
            const SizedBox(height: 12),
            Text('ID: ${patient.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /* ---------------------------------------------------------
   *        S H O W   D E L E T E   C O N F I R M A T I O N
   * -------------------------------------------------------*/
  void _showDeleteConfirmation(Patient patient) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Patient?'),
        content: Text('Are you sure you want to delete ${patient.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePatient(patient);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}