import 'package:flutter/material.dart';

class ManagePage extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onSearch;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManagePage({
    super.key,
    required this.onAdd,
    required this.onSearch,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _actionButton(context, 'Add User', Icons.person_add, Colors.teal, onAdd),
            const SizedBox(height: 20),
            _actionButton(context, 'Search Users', Icons.search, Colors.indigo, onSearch),
            const SizedBox(height: 20),
            _actionButton(context, 'Edit Users', Icons.edit, Colors.orange, onEdit),
            const SizedBox(height: 20),
            _actionButton(context, 'Delete Users', Icons.delete, Colors.red, onDelete),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext ctx, String text, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}