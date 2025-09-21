import 'package:flutter/material.dart';
import '../models/models.dart';
import 'edit_user_page_view.dart';

/// Pen-only list: no trash icon.
class EditOnlyPage extends StatefulWidget {
  final List<User> users;
  final Function(int, User) onUpdate;
  const EditOnlyPage({super.key, required this.users, required this.onUpdate});

  @override
  State<EditOnlyPage> createState() => _EditOnlyPageState();
}

class _EditOnlyPageState extends State<EditOnlyPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.users
        .where((u) => u.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Edit Users', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          // ----------  SEARCH FIELD  ----------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => setState(() => search = val),
              ),
            ),
          ),
          // ----------  LIST  ----------
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          widget.users.isEmpty ? 'No users found' : 'No results for "$search"',
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
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final user = filtered[index];
                      final rem = user.visits.isEmpty ? 0.0 : user.visits.last.remainingUSD;
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade300, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 24),
                          ),
                          title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Remaining: \$${rem.toStringAsFixed(2)}'),
                          trailing: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditUserPage(
                                    user: user,
                                    onSave: (updated) {
                                      widget.onUpdate(widget.users.indexOf(user), updated);
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
    );
  }
}