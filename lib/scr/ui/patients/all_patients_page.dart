import 'package:flutter/material.dart';
import '../../models/models.dart';

class UsersPage extends StatefulWidget {
  final List<User> users;
  final Function(User) onView;
  final bool startInSearchMode;

  const UsersPage({
    super.key,
    required this.users,
    required this.onView,
    this.startInSearchMode = false,
  });

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String search = '';

  @override
  void initState() {
    super.initState();
    if (widget.startInSearchMode) search = '';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.users
        .where((u) => u.name.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Users', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => search = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
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
                                      color: const Color(0xFF6366F1)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: Color(0xFF6366F1), size: 24),
                                  ),
                                  title: Text(user.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle:
                                      Text('Remaining: \$${rem.toStringAsFixed(2)}'),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey),
                                  onTap: () => widget.onView(user),
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