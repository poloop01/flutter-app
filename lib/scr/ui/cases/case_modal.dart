import 'package:flutter/material.dart';
import '../../models/patients.dart';
import 'package:intl/intl.dart';          // <-- added for nice date formatting
import 'package:uuid/uuid.dart';           // already used in models

/// Dialog for adding a new case - returns (title, status, notes) or null if cancelled.
class AddCaseModal extends StatefulWidget {
  const AddCaseModal({super.key});

  @override
  State<AddCaseModal> createState() => _AddCaseModalState();
}

class _AddCaseModalState extends State<AddCaseModal> {
  late TextEditingController titleCtrl;
  late TextEditingController notesCtrl;
  late TextEditingController dateCtrl;           // <-- NEW: date controller
  late GlobalKey<FormState> formKey;
  String selectedStatus = 'open';

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController();
    notesCtrl = TextEditingController();
    dateCtrl = TextEditingController();          // <-- initialise
    formKey = GlobalKey<FormState>();

    // Pre-fill today's date (you can leave it empty if you prefer)
    dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    notesCtrl.dispose();
    dateCtrl.dispose();                          // <-- dispose new controller
    super.dispose();
  }

  // Helper to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.folder_outlined, color: Colors.blue, size: 32),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Add New Case',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  // Title field
                  TextFormField(
                    controller: titleCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Case Title *',
                      hintText: 'Enter case title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ==== NEW: Case Date Field (under title) ====
                  TextFormField(
                    controller: dateCtrl,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Case Date *',
                      hintText: 'Select case date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Case date is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status *',
                      prefixIcon: const Icon(Icons.check_circle_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'finished', child: Text('Finished')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value ?? 'open');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add any notes...',
                      prefixIcon: const Icon(Icons.note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final now = DateTime.now().toIso8601String();

                        Navigator.of(context).pop(
                          (
                            titleCtrl.text.trim(),
                            dateCtrl.text.trim(),          // <-- new field
                            selectedStatus,
                            notesCtrl.text.trim(),
                            now,   // createdAt
                            now,   // updatedAt
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Add Case'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for editing an existing case
class EditCaseModal extends StatefulWidget {
  final Case caseData;

  const EditCaseModal({required this.caseData, super.key});

  @override
  State<EditCaseModal> createState() => _EditCaseModalState();
}

class _EditCaseModalState extends State<EditCaseModal> {
  late TextEditingController titleCtrl;
  late TextEditingController notesCtrl;
  late TextEditingController dateCtrl;           // <-- NEW
  late GlobalKey<FormState> formKey;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.caseData.title);
    notesCtrl = TextEditingController(text: widget.caseData.notes);
    dateCtrl = TextEditingController(text: widget.caseData.caseDate);   // <-- load existing
    selectedStatus = widget.caseData.status;
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    notesCtrl.dispose();
    dateCtrl.dispose();                          // <-- dispose
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.caseData.caseDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.edit_outlined, color: Colors.orange, size: 32),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Edit Case',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),

            // Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  // Title field
                  TextFormField(
                    controller: titleCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Case Title *',
                      hintText: 'Enter case title',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ==== NEW: Case Date Field (under title) ====
                  TextFormField(
                    controller: dateCtrl,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Case Date *',
                      hintText: 'Select case date',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Case date is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status *',
                      prefixIcon: const Icon(Icons.check_circle_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open')),
                      DropdownMenuItem(value: 'finished', child: Text('Finished')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value ?? 'open');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes field
                  TextFormField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add any notes...',
                      prefixIcon: const Icon(Icons.note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: Navigator.of(context).pop,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final now = DateTime.now().toIso8601String();

                        Navigator.of(context).pop(
                          (
                            titleCtrl.text.trim(),
                            dateCtrl.text.trim(),          // <-- updated case date
                            selectedStatus,
                            notesCtrl.text.trim(),
                            widget.caseData.createdAt,     // keep original createdAt
                            now,                           // updatedAt = now
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}