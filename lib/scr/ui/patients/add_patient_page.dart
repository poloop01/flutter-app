import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/models.dart';
import '../../services/image_helper.dart';
import 'package:uuid/uuid.dart';

class AddUserPage extends StatefulWidget {
  final List<User> users;
  final Function(Visit, String, User?) onSave;
  const AddUserPage({super.key, required this.users, required this.onSave});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final dateC = TextEditingController();
  final teethC = TextEditingController();
  final illnessC = TextEditingController();
  final whatWasDoneC = TextEditingController();
  final totalC = TextEditingController();
  final paidC = TextEditingController();
  final remC = TextEditingController();

  User? selectedUser;
  final List<Uint8List> _rawImages = [];

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    for (final xFile in picked) {
      _rawImages.add(await xFile.readAsBytes());
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    dateC.text = DateTime.now().toIso8601String().split('T')[0];
    _updateVisitCount();
  }

  @override
  void dispose() {
    nameC.dispose();
    dateC.dispose();
    teethC.dispose();
    illnessC.dispose();
    whatWasDoneC.dispose();
    totalC.dispose();
    paidC.dispose();
    remC.dispose();
    super.dispose();
  }

  void _updateVisitCount() {
    if (mounted) setState(() {});
  }

  int get _visitNumber => (selectedUser?.visits.length ?? 0) + 1;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateC.text = picked.toIso8601String().split('T')[0];
  }

  void _calcRem() {
    final t = double.tryParse(totalC.text) ?? 0;
    final p = double.tryParse(paidC.text) ?? 0;
    remC.text = (t - p).toStringAsFixed(2);
  }

  bool _step1Pass() =>
      nameC.text.trim().isNotEmpty &&
      teethC.text.trim().isNotEmpty &&
      illnessC.text.trim().isNotEmpty &&
      whatWasDoneC.text.trim().isNotEmpty;

  bool _step2Pass() {
    final t = double.tryParse(totalC.text.trim());
    final p = double.tryParse(paidC.text.trim());
    if (t == null || p == null) return false;
    return p <= t;
  }

  void _save() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    if (!_step1Pass()) return;
    if (!_step2Pass()) return;

    final userId = selectedUser?.id ?? const Uuid().v4();
    final visitIdx = (selectedUser?.visits.length ?? 0) + 1;

    final List<String> savedNames = [];
    for (final raw in _rawImages) {
      final n = await ImageHelper.save(raw,
          userId: userId, visitIndex: visitIdx);
      savedNames.add(n);
    }

    final visit = Visit(
      date: dateC.text,
      illness: illnessC.text.trim(),
      teethIllness: teethC.text.trim(),
      whatWasDone: whatWasDoneC.text.trim(),
      totalUSD: double.parse(totalC.text.trim()),
      paidUSD: double.parse(paidC.text.trim()),
      remainingUSD: double.parse(remC.text.trim()),
      imageNames: savedNames,
    );

    widget.onSave(visit, nameC.text.trim(), selectedUser);

    if (selectedUser == null) {
      _formKey.currentState!.reset();
      nameC.clear();
      teethC.clear();
      illnessC.clear();
      whatWasDoneC.clear();
      totalC.clear();
      paidC.clear();
      remC.clear();
      _rawImages.clear();
      dateC.text = DateTime.now().toIso8601String().split('T')[0];
      selectedUser = null;
      _updateVisitCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('New Patient Data', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final hPadding = isTablet ? 32.0 : 16.0;
            final vPadding = isTablet ? 24.0 : 16.0;
            final fieldSpacing = isTablet ? 20.0 : 16.0;
            final maxFieldWidth = isTablet ? 600.0 : double.infinity;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxFieldWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('Personal Information', [
                        _textField(nameC, 'Name *', Icons.person_outline,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        SizedBox(height: fieldSpacing),
                        _dateWithVisitCounter(),
                        SizedBox(height: fieldSpacing),
                        _textField(teethC, 'Teeth Illness *', Icons.medical_services, maxLines: 5,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        _textField(illnessC, 'Other Illnesses *', Icons.local_hospital, maxLines: 5,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        _textField(whatWasDoneC, 'Treatment Description *', Icons.healing, maxLines: 5,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      ]),
                      SizedBox(height: fieldSpacing),
                      _section('Financial Information', [
                        _textField(totalC, 'Total USD *', Icons.account_balance_wallet,
                            isNumber: true,
                            onChanged: (_) => _calcRem(),
                            validator: _totalValidator),
                        _textField(paidC, 'Paid USD *', Icons.check_circle,
                            isNumber: true,
                            onChanged: (_) => _calcRem(),
                            validator: _paidValidator),
                        _textField(remC, 'Remaining USD', Icons.pending,
                            enabled: false, labelColor: Colors.orange),
                      ]),
                      SizedBox(height: fieldSpacing),
                      _section('Photos (optional)', [
                        if (_rawImages.isNotEmpty) _imageThumbnails(),
                        _addPhotoButton(),
                      ]),
                      SizedBox(height: fieldSpacing * 1.5),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text('Save as a New Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color.fromARGB(255, 60, 148, 232),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: fieldSpacing),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Add a visit for Existing Patient'),
                          onPressed: _selectExistingUser,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _addPhotoButton() => OutlinedButton.icon(
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add photo(s)'),
        onPressed: _pickImages,
      );

  Widget _imageThumbnails() => SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _rawImages.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: MemoryImage(_rawImages[i]), fit: BoxFit.cover),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                onPressed: () => setState(() => _rawImages.removeAt(i)),
              ),
            ],
          ),
        ),
      );

  Widget _dateWithVisitCounter() {
    return Column(
      children: [
        _textField(dateC, 'Date *', Icons.calendar_today,
            readOnly: true, onTap: _pickDate,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        const SizedBox(height: 8),
        _visitCounterCard(),
      ],
    );
  }

  Widget _visitCounterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 121, 203, 182), const Color.fromARGB(255, 63, 134, 181)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: .3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            'This is visit #$_visitNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  String? _totalValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final d = double.tryParse(v.trim());
    if (d == null) return 'Invalid number';
    if (d < 0) return 'Cannot be negative';
    return null;
  }

  String? _paidValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final p = double.tryParse(v.trim());
    if (p == null) return 'Invalid number';
    if (p < 0) return 'Cannot be negative';
    final t = double.tryParse(totalC.text.trim());
    if (t != null && p > t) return 'Cannot exceed Total USD';
    return null;
  }

  Widget _textField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool enabled = true,
    bool readOnly = false,
    int maxLines = 1,
    Color? labelColor,
    VoidCallback? onTap,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        readOnly: readOnly,
        enabled: enabled,
        maxLines: maxLines,
        keyboardType: isNumber
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
            : null,
        onTap: onTap,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor ?? Colors.grey.shade600),
          prefixIcon: Icon(icon, color: enabled ? const Color.fromARGB(255, 3, 158, 255) : Colors.grey),
          errorStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void _selectExistingUser() {
    String dialogSearch = '';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) {
          final filtered = widget.users
              .where((u) => u.name.toLowerCase().contains(dialogSearch.toLowerCase()))
              .toList();
          return AlertDialog(
            title: const Text('Select User for New Visit'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (v) => setSt(() => dialogSearch = v),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No users'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final u = filtered[i];
                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(u.name),
                              subtitle: Text('Visits: ${u.visits.length}'),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() {
                                  selectedUser = u;
                                  _updateVisitCount();
                                  nameC.text = u.name;
                                  if (u.visits.isNotEmpty) {
                                    final last = u.visits.last;
                                    dateC.text = last.date;
                                    illnessC.text = last.illness;
                                    teethC.text = last.teethIllness;
                                    whatWasDoneC.text = last.whatWasDone;
                                    totalC.text = last.totalUSD.toString();
                                    paidC.text = last.paidUSD.toString();
                                    remC.text = last.remainingUSD.toStringAsFixed(2);
                                  } else {
                                    dateC.text = DateTime.now().toIso8601String().split('T')[0];
                                    illnessC.clear();
                                    teethC.clear();
                                    whatWasDoneC.clear();
                                    totalC.clear();
                                    paidC.clear();
                                    remC.clear();
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
              ])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel'))
            ],
          );
        },
      ),
    );
  }
}