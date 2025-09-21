import 'package:flutter/material.dart';
import '../models/models.dart';

/// Trash-only list: no edit icon.
class DeleteOnlyPage extends StatefulWidget {
  final List<User> users;
  final Function(int) onDelete;
  const DeleteOnlyPage({super.key, required this.users, required this.onDelete});

  @override
  State<DeleteOnlyPage> createState() => _DeleteOnlyPageState();
}

class _DeleteOnlyPageState extends State<DeleteOnlyPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    // rebuild every time the list changes
    final filtered = widget.users
        .where((u) => u.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Delete Users', style: TextStyle(fontWeight: FontWeight.bold))),
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
                        Icon(Icons.delete_outlined, size: 64, color: Colors.grey.shade400),
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
                                colors: [Colors.red.shade300, Colors.red],
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
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete User'),
                                  content: Text('Are you sure you want to delete ${user.name}?'),
                                  actions: [
TextButton(
  onPressed: () => Navigator.pop(context), // or Navigator.of(context).pop()
  child: const Text('Cancel'),
),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () {
                                        // 1. delete from disk (MainPage already removes it)
                                        widget.onDelete(widget.users.indexOf(user));
                                        // 2. close dialog
                                        Navigator.pop(context);
                                        // 3. refresh UI instantly
                                        setState(() {});
                                        // 4. snack-bar
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(children: [
                                              Icon(Icons.delete, color: Colors.white, size: 20),
                                              SizedBox(width: 8),
                                              Text("User deleted successfully!"),
                                            ]),
                                            backgroundColor: Colors.red.shade600,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            margin: const EdgeInsets.all(16),
                                          ),
                                        );
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
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