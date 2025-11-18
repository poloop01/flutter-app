import 'package:flutter/material.dart';
import '../../models/patients.dart';

/// Compact dialog for adding a new patient - returns (name, phone) or null if cancelled.
class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
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
              child: const Icon(Icons.person_add, color: Colors.blue, size: 32),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Add New Patient',
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
                  // Name field
                  TextFormField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter patient name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
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
                        Navigator.of(context).pop(
                          (nameCtrl.text.trim(), phoneCtrl.text.trim()),
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
                    child: const Text('Add Patient'),
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

/// Dialog for editing an existing patient - returns (name, phone) or null if cancelled.
class EditPatientDialog extends StatefulWidget {
  final Patient patient;

  const EditPatientDialog({required this.patient, super.key});

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.patient.name);
    phoneCtrl = TextEditingController(text: widget.patient.phone);
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
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
              'Edit Patient',
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
                  // Name field
                  TextFormField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter patient name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
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
                        Navigator.of(context).pop(
                          (nameCtrl.text.trim(), phoneCtrl.text.trim()),
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