// import 'package:flutter/material.dart';
// import '../models/models.dart';
// import 'edit_user_page_view.dart';

// class EditDeletePage extends StatefulWidget {
//   final List<User> users;
//   final Function(int, User) onUpdate;
//   final Function(int) onDelete;
//   const EditDeletePage({super.key, required this.users, required this.onUpdate, required this.onDelete});

//   @override
//   State<EditDeletePage> createState() => _EditDeletePageState();
// }

// class _EditDeletePageState extends State<EditDeletePage> {
//   String search = '';

//   @override
//   Widget build(BuildContext context) {
//     final filtered = widget.users
//         .where((u) => u.name.toLowerCase().contains(search.toLowerCase()))
//         .toList();

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(title: const Text('Edit/Delete Users', style: TextStyle(fontWeight: FontWeight.bold))),
//       body: Column(children: [
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: 'Search by name...',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//               filled: true,
//               fillColor: Colors.grey.shade100,
//             ),
//             onChanged: (v) => setState(() => search = v),
//           ),
//         ),
//         Expanded(
//           child: filtered.isEmpty
//               ? Center(
//                   child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//                     Icon(Icons.edit_outlined, size: 64, color: Colors.grey.shade400),
//                     const SizedBox(height: 16),
//                     Text(widget.users.isEmpty ? 'No users found' : 'No results for "$search"'),
//                   ]),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filtered.length,
//                   itemBuilder: (_, i) {
//                     final u = filtered[i];
//                     final actualIndex = widget.users.indexOf(u);
//                     final rem = u.visits.isEmpty ? 0.0 : u.visits.last.remainingUSD;
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       child: ListTile(
//                         leading: Container(
//                           width: 48,
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(.1),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Icon(Icons.person, color: Color(0xFF6366F1)),
//                         ),
//                         title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                         subtitle: Text('Remaining: \$${rem.toStringAsFixed(2)}'),
//                         trailing: Row(mainAxisSize: MainAxisSize.min, children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => EditUserPageView(
//                                   user: u,
//                                   onSave: (updated) {
//                                     widget.onUpdate(actualIndex, updated);
//                                     if (!mounted) return;
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: const Row(children: [
//                                           Icon(Icons.check_circle, color: Colors.white, size: 20),
//                                           SizedBox(width: 8),
//                                           Text("User updated successfully!"),
//                                         ]),
//                                         backgroundColor: Colors.green.shade600,
//                                         behavior: SnackBarBehavior.floating,
//                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                         margin: const EdgeInsets.all(16),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => showDialog(
//                               context: context,
//                               builder: (_) => AlertDialog(
//                                 title: const Text('Delete User'),
//                                 content: Text('Are you sure you want to delete ${u.name}? This will delete all visits.'),
//                                 actions: [
//                                   TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//                                   ElevatedButton(
//                                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
//                                     onPressed: () {
//                                       widget.onDelete(actualIndex);
//                                       Navigator.pop(context);
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: const Row(children: [
//                                             Icon(Icons.delete, color: Colors.white, size: 20),
//                                             SizedBox(width: 8),
//                                             Text("User deleted successfully!"),
//                                           ]),
//                                           backgroundColor: Colors.red.shade600,
//                                           behavior: SnackBarBehavior.floating,
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                           margin: const EdgeInsets.all(16),
//                                         ),
//                                       );
//                                     },
//                                     child: const Text('Delete'),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ]),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ]),
//     );
//   }
// }