import 'package:flutter/material.dart';
import '../storage/storage.dart';
import '../models/models.dart';
import 'home_page.dart';
import 'manage_page.dart';
import 'users_page.dart';
import 'add_user_page.dart';
import 'edit_only_page.dart';
import 'delete_only_page.dart';
import 'view_user_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0; // 0 = Home , 1 = Manage , 2 = Settings
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _load(); // Storage.init() is called inside Storage.loadUsers()
  }

  Future<void> _load() async {
    final loaded = await Storage.loadUsers();
    setState(() => users = loaded);
  }

  Future<void> _save() async => Storage.saveUsers(users);

  /* ----------  CRUD helpers that ALWAYS persist  ---------- */
  Future<void> _addUser(User u) async {
    users.add(u);
    await _save();
  }

  Future<void> _updateUser(int i, User u) async {
    users[i] = u;
    await _save();
  }

  Future<void> _deleteUser(int i) async {
    users.removeAt(i);
    await _save();
  }

  /* ----------  SAVE NEW VISIT (used by AddUserPage)  ---------- */
  void _handleSave(Visit v, String name, User? existing) {
    if (existing != null) {
      users[users.indexOf(existing)].visits.add(v);
    } else {
      users.add(User(name: name, visits: [v]));
    }
    _save().then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Saved successfully!"),
          ]),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  /* ----------  NAVIGATION HELPERS  ---------- */
  void _goAdd() => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => AddUserPage(users: users, onSave: _handleSave)),
      );

  void _goSearch() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UsersPage(
            users: users,
            onView: (user) => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ViewUserPage(user: user)),
            ),
            startInSearchMode: true,
          ),
        ),
      );

  void _goEdit() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditOnlyPage(users: users, onUpdate: _updateUser),
        ),
      );

  void _goDelete() => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeleteOnlyPage(users: users, onDelete: _deleteUser),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(users: users),
      ManagePage(
        onAdd: _goAdd,
        onSearch: _goSearch,
        onEdit: _goEdit,
        onDelete: _goDelete,
      ),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Manage'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}