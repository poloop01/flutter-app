import 'package:flutter/material.dart';
// import '../../storage/patients_storage.dart';
import '../../storage/appointment_storage.dart';
// import '../../models/patients.dart';
import '../../models/appointment.dart';

/*  -----  user screens  -----  */
import '../home/home_page.dart';
import '../settings/settings_page.dart';
// import '../patients/patients_page.dart';
// import '../patients/add_patient_page.dart';
// import '../patients/edit_search_patient_page.dart';
// import '../patients/delete_patient_page.dart';
// import '../patients/view_patient_page.dart';
// import '../settings/settings_page.dart';
// import '../patients/all_patients_page.dart';

/*  -----  appointment screens  -----  */
import '../appointments/appointment_page.dart';
import '../appointments/add_appointment_page.dart';
import '../appointments/all_appointments_page.dart';
import '../appointments/edit_appointment_page_view.dart';
import '../appointments/edit_search_appointment_page.dart';
import '../appointments/delete_appointment_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;          // 0 Home, 1 Appointments, 2 Manage, 3 Settings

  // List<User> users = [];
  List<Appointment> appointments = [];

  /* ================================================================
   *                       L I F E – C Y C L E
   * ==============================================================*/
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // final loadedUsers = await Storage.loadUsers();
    final loadedAppointments = await AppointmentStorage.load();
    setState(() {
      // users = loadedUsers;
      appointments = loadedAppointments;
    });
  }

  // Future<void> _saveUsers() async => Storage.saveUsers(users);
  Future<void> _saveAppointments() async => AppointmentStorage.save(appointments);

  /* ================================================================
   *                      U S E R   C R U D
   * ==============================================================*/
  // Future<void> _addUser(User u) async {
  //   users.add(u);
  //   await _saveUsers();
  // }

  // Future<void> _updateUser(int i, User u) async {
  //   users[i] = u;
  //   await _saveUsers();
  // }

  // Future<void> _deleteUser(int i) async {
  //   users.removeAt(i);
  //   await _saveUsers();
  // }

  /* ================================================================
   *                  A P P O I N T M E N T   C R U D
   * ==============================================================*/
  Future<void> _addAppointment(Appointment a) async {
    appointments.add(a);
    await _saveAppointments();
  }

  Future<void> _updateAppointment(int i, Appointment a) async {
    appointments[i] = a;
    await _saveAppointments();
  }

  Future<void> _deleteAppointment(int i) async {
    appointments.removeAt(i);
    await _saveAppointments();
  }

  /* ================================================================
   *                        V I S I T   S A V E
   * ==============================================================*/
  // void _handleSave(Visit v, String name, User? existing) {
  //   if (existing != null) {
  //     users[users.indexOf(existing)].visits.add(v);
  //   } else {
  //     users.add(User(name: name, visits: [v]));
  //   }
  //   _saveUsers().then((_) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Row(children: [
  //           Icon(Icons.check_circle, color: Colors.white, size: 20),
  //           SizedBox(width: 8),
  //           Text("Saved successfully!"),
  //         ]),
  //         backgroundColor: Colors.green.shade600,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         margin: const EdgeInsets.all(16),
  //       ),
  //     );
  //   });
  // }

  /* ================================================================
   *                        N A V I G A T I O N
   * ==============================================================*/
  /* ---------------  USER  --------------- */
  // void _goAddUser() => Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => AddUserPage(users: users, onSave: _handleSave),
  //       ),
  //     );

  // void _goSearchUser() => Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => UsersPage(
  //           users: users,
  //           onView: (user) => Navigator.of(context).push(
  //             MaterialPageRoute(builder: (_) => ViewUserPage(user: user)),
  //           ),
  //           startInSearchMode: true,
  //         ),
  //       ),
  //     );

  // void _goEditUser() => Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => EditOnlyPage(users: users, onUpdate: _updateUser),
  //       ),
  //     );

  // void _goDeleteUser() => Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => DeleteOnlyPage(users: users, onDelete: _deleteUser),
  //       ),
  //     );

  /*  -----------  A P P O I N T M E N T  -----------  */
  void _goAddAppointment() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddAppointmentPage(onSave: _addAppointment),
        ),
      );

void _goSearchAppointment() =>
    Navigator.of(context).push<List<Appointment>>(
      MaterialPageRoute(
        builder: (_) => AllAppointmentsPage(
          appointments: appointments,
          onChanged: (updated) async {
            appointments = updated;
            await AppointmentStorage.save(appointments); // use the same helper
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

void _goDeleteAppointment() =>
    Navigator.of(context).push<List<Appointment>>(
      MaterialPageRoute(
        builder: (_) => DeleteOnlyAppointmentPage(
          appointments: appointments,
          onChanged: (updated) async {   // updated list comes back here
            appointments = updated;
            await AppointmentStorage.save(appointments); // write to JSON
            setState(() {});
          },
        ),
      ),
    );

  /* ================================================================
   *                           B U I L D
   * ==============================================================*/
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(/*users: users,*/ appointments: appointments,),
      AppointmentPage(          // four-button design
        onAdd: _goAddAppointment,
        onSearch: _goSearchAppointment,
        onEdit: _goEditAppointment,
        onDelete: _goDeleteAppointment,
      ),
      // ManagePage(
      //   onAdd: _goAddUser,
      //   onSearch: _goSearchUser,
      //   onEdit: _goEditUser,
      //   onDelete: _goDeleteUser,
      // ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), label: 'Appointments'),
          // NavigationDestination(icon: Icon(Icons.supervised_user_circle), label: 'Patients'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}