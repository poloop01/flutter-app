import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/image_helper.dart';

/// Trash-only list: deletes user + all visit-images.
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
    final filtered = widget.users
        .where((u) => u.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Delete Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              padding: EdgeInsets.symmetric(
                horizontal: hPadding,
                vertical: vPadding,
              ),
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
                        hintText: 'Search by name...',
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
                                Icon(Icons.delete_outline,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  widget.users.isEmpty
                                      ? 'No users found'
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
                              final user = filtered[index];
                              final rem = user.visits.isEmpty
                                  ? 0.0
                                  : user.visits.last.remainingUSD;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade300,
                                          Colors.red
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: Colors.white, size: 24),
                                  ),
                                  title: Text(user.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      'Remaining: \$${rem.toStringAsFixed(2)}'),
                                  trailing: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete User'),
                                          content: Text(
                                              'Are you sure you want to delete ${user.name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () async {
                                                // 1️⃣ delete all visit-images
                                                for (final v in user.visits) {
                                                  for (final name
                                                      in v.imageNames) {
                                                    await ImageHelper.delete(
                                                        name);
                                                  }
                                                }
                                                // 2️⃣ remove user from JSON
                                                widget.onDelete(widget.users
                                                    .indexOf(user));
                                                // 3️⃣ close dialog + refresh
                                                Navigator.pop(context);
                                                setState(() {});
                                                // 4️⃣ snack-bar
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Row(
                                                        children: [
                                                          Icon(Icons.delete,
                                                              color:
                                                                  Colors.white,
                                                              size: 20),
                                                          SizedBox(width: 8),
                                                          Text(
                                                              "User & images deleted!"),
                                                        ],
                                                      ),
                                                      backgroundColor:
                                                          Colors.red.shade600,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      margin:
                                                          const EdgeInsets.all(
                                                              16),
                                                    ),
                                                  );
                                                }
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
            ),
          );
        },
      ),
    );
  }
}
