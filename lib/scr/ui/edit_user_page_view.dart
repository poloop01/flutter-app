import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/image_helper.dart';

/// Edit ONE visit inside a user – optional multi-image gallery.
class EditUserPage extends StatefulWidget {
  final User user;
  final Function(User) onSave;
  const EditUserPage({super.key, required this.user, required this.onSave});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late int selectedIndex;
  late TextEditingController nameC,
      dateC,
      teethC,
      illnessC,
      whatWasDoneC,
      totalC,
      paidC,
      remC;

  final List<Uint8List> _rawImages = [];
  final List<String> _currentNames = [];
  bool _loading = false;
  bool _imagesAdded = false;

  Future<void> _pickImages() async {
    final picked = await ImagePicker().pickMultiImage();
    for (final xFile in picked) {
      _rawImages.add(await xFile.readAsBytes());
    }
    _imagesAdded = true;
    setState(() {});
  }

  Future<void> _loadImages() async {
    setState(() => _loading = true);
    _rawImages.clear();
    for (final name in _currentNames) {
      final bytes = await ImageHelper.load(name);
      if (bytes != null) _rawImages.add(bytes);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteExistingImage(int idx) async {
    final bool? delete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Image'),
        content: const Text('Remove this picture permanently?'),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (delete != true) return;

    final fileName = _currentNames.removeAt(idx);
    _rawImages.removeAt(idx);
    await ImageHelper.delete(fileName);

    final updatedVisit = Visit(
      date: dateC.text,
      illness: illnessC.text.trim(),
      teethIllness: teethC.text.trim(),
      whatWasDone: whatWasDoneC.text.trim(),
      totalUSD: double.parse(totalC.text.trim()),
      paidUSD: double.parse(paidC.text.trim()),
      remainingUSD: double.parse(remC.text.trim()),
      imageNames: List.of(_currentNames),
    );

    widget.user.visits[selectedIndex] = updatedVisit;
    widget.onSave(widget.user);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.delete, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Image deleted & saved the changes"),
          ]),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _initControllers();
  }

  void _initControllers() {
    nameC = TextEditingController(text: widget.user.name);
    if (widget.user.visits.isEmpty) {
      dateC = TextEditingController();
      teethC = TextEditingController();
      illnessC = TextEditingController();
      whatWasDoneC = TextEditingController();
      totalC = TextEditingController();
      paidC = TextEditingController();
      remC = TextEditingController();
      _currentNames.clear();
    } else {
      final v = widget.user.visits[selectedIndex];
      dateC = TextEditingController(text: v.date);
      teethC = TextEditingController(text: v.teethIllness);
      illnessC = TextEditingController(text: v.illness);
      whatWasDoneC = TextEditingController(text: v.whatWasDone);
      totalC = TextEditingController(text: v.totalUSD.toString());
      paidC = TextEditingController(text: v.paidUSD.toString());
      remC = TextEditingController(text: v.remainingUSD.toStringAsFixed(2));
      _currentNames.clear();
      _currentNames.addAll(v.imageNames);
    }
    _rawImages.clear();
    _imagesAdded = false;
    _loadImages();
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
      dateC.text.trim().isNotEmpty &&
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

    setState(() => _loading = true);

    for (final oldName in _currentNames) {
      await ImageHelper.delete(oldName);
    }

    final newNames = <String>[];
    for (final raw in _rawImages) {
      final n = await ImageHelper.save(raw,
          userId: widget.user.id, visitIndex: selectedIndex);
      newNames.add(n);
    }

    final updatedVisit = Visit(
      date: dateC.text,
      illness: illnessC.text.trim(),
      teethIllness: teethC.text.trim(),
      whatWasDone: whatWasDoneC.text.trim(),
      totalUSD: double.parse(totalC.text.trim()),
      paidUSD: double.parse(paidC.text.trim()),
      remainingUSD: double.parse(remC.text.trim()),
      imageNames: newNames,
    );

    widget.user.visits[selectedIndex] = updatedVisit;
    widget.onSave(widget.user);
    if (mounted) {
      setState(() {
        _loading = false;
        _imagesAdded = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Visit updated successfully!"),
          ]),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.visits.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Edit User')),
          body: const Center(child: Text('No visits to edit')));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
          title: const Text('Edit User',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 600;
                final hPad = isTablet ? 32.0 : 16.0;
                final vPad = isTablet ? 24.0 : 16.0;
                final maxW = isTablet ? 800.0 : double.infinity;

                return Center(
                  child: Container(
                    width: maxW,
                    padding:
                        EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(isTablet ? 20 : 16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: DropdownButton<int>(
                                  value: selectedIndex + 1,
                                  isExpanded: true,
                                  items: List.generate(
                                    widget.user.visits.length,
                                    (i) => DropdownMenuItem(
                                        value: i + 1,
                                        child: Text('Record ${i + 1}')),
                                  ),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        selectedIndex = v - 1;
                                        _initControllers();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _section('Personal Information', [
                              _field(nameC, 'Name', Icons.person,
                                  enabled: false),
                              _field(dateC, 'Date *', Icons.calendar_today,
                                  readOnly: true,
                                  onTap: _pickDate,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null),
                              const SizedBox(height: 8),
                              _visitCounterCard(),
                              const SizedBox(height: 8),
                              _field(teethC, 'Teeth Illness *',
                                  Icons.medical_services,
                                  maxLines: 5,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null),
                              _field(illnessC, 'Other Illnesses *',
                                  Icons.local_hospital,
                                  maxLines: 5,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null),
                              _field(
                                  whatWasDoneC, 'Treatment Description *',
                                  Icons.healing,
                                  maxLines: 5,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Required'
                                          : null),
                            ]),
                            const SizedBox(height: 8),
                            _section('Financial Information', [
                              _field(totalC, 'Total USD *',
                                  Icons.account_balance_wallet,
                                  isNumber: true,
                                  onChanged: (_) => _calcRem(),
                                  validator: _totalValidator),
                              _field(paidC, 'Paid USD *', Icons.check_circle,
                                  isNumber: true,
                                  onChanged: (_) => _calcRem(),
                                  validator: _paidValidator),
                              _field(remC, 'Remaining USD', Icons.pending,
                                  enabled: false, labelColor: Colors.orange),
                            ]),
                            const SizedBox(height: 8),
                            _section('Photos (optional)', [
                              if (_imagesAdded)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Please click the "Save Changes" button to save the new images.',
                                    style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 12),
                                  ),
                                ),
                              if (_loading)
                                const Center(child: CircularProgressIndicator())
                              else if (_rawImages.isNotEmpty)
                                SizedBox(
                                  height: 100,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _rawImages.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (_, i) => Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            image: DecorationImage(
                                              image: MemoryImage(_rawImages[i]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red, size: 20),
                                          onPressed: () =>
                                              _deleteExistingImage(i),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              _addPhotoButton(),
                            ]),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save Changes',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                onPressed: _save,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color.fromARGB(255, 244, 136, 21),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(isTablet ? 16 : 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _visitCounterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 177, 179, 51), const Color.fromARGB(255, 181, 116, 63)],
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
            'This is visit #${selectedIndex + 1}',
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

  Widget _field(
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
          prefixIcon: Icon(icon, color: enabled ? const Color.fromARGB(255, 201, 116, 18) : Colors.grey),
          errorStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _addPhotoButton() => OutlinedButton.icon(
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add photo(s)'),
        onPressed: _pickImages,
      );
}