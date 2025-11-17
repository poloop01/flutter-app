import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/patients.dart';   // real Patient model

/* ----------------------------------------------------------
 *  MODEL  –  uses the imported Patient class
 * ---------------------------------------------------------- */

/* ----------------------------------------------------------
 *  STORAGE
 * ---------------------------------------------------------- */
class PatientStore {
  static late File _file;

  static Future<void> _init() async {
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/data');
    await dir.create(recursive: true);
    _file = File('${dir.path}/patients.json');
  }

  static Future<List<Patient>> load() async {
    await _init();
    if (!await _file.exists()) return [];
    final raw = await _file.readAsString();
    if (raw.trim().isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> save(List<Patient> list) async {
    await _init();
    await _file.writeAsString(jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}

/* ----------------------------------------------------------
 *  PUBLIC MODAL HELPER
 * ---------------------------------------------------------- */
Future<void> showAddPatientModal(
  BuildContext context, {
  required void Function(List<Patient> updated) onSave,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddPatientModal(onSave: onSave),
  );
}

/* ----------------------------------------------------------
 *  MODAL CONTENT
 * ---------------------------------------------------------- */
class AddPatientModal extends StatefulWidget {
  const AddPatientModal({required this.onSave});
  final void Function(List<Patient> updated) onSave;

  @override
  State<AddPatientModal> createState() => AddPatientModalState();
}

class AddPatientModalState extends State<AddPatientModal> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  List<Patient> patients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    patients = await PatientStore.load();
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final newOne = Patient(name: _name.text.trim(), phone: _phone.text.trim());
    patients.add(newOne);
    await PatientStore.save(patients);
    widget.onSave(patients);
    _name.clear();
    _phone.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _delete(Patient p) async {
    patients.removeWhere((e) => e.id == p.id);
    await PatientStore.save(patients);
    widget.onSave(patients);
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Patients', style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: Navigator.of(context).pop,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Patient'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          Flexible(
            child: patients.isEmpty
                ? const Center(child: Text('No patients yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: patients.length,
                    itemBuilder: (_, i) {
                      final p = patients[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(p.name),
                          subtitle: Text(p.phone.isEmpty ? '—' : p.phone),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _delete(p),
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