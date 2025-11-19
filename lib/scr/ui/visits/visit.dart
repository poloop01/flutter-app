import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/patients.dart';
import '../../storage/patients_storage.dart';

class VisitDetailsPage extends StatefulWidget {
  final Patient patient;
  final Case currentCase;
  final Visit visit;
  final Function(Case updatedCase) onVisitUpdated;

  const VisitDetailsPage({
    required this.patient,
    required this.currentCase,
    required this.visit,
    required this.onVisitUpdated,
    super.key,
  });

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  late bool _isEditMode;
  late DateTime _visitDate;
  late TextEditingController _teethIllnessController;
  late TextEditingController _illnessController;
  late TextEditingController _whatWasDoneController;
  late TextEditingController _totalUsdController;
  late TextEditingController _paidUsdController;
  late List<Uint8List> _rawImages;
  late List<String> _existingImageNames;

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _hasExistingTotal = false;
  String _totalMessage = '';
  Color _totalMessageColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _isEditMode = false;
    _visitDate = DateTime.parse(widget.visit.date);
    _teethIllnessController = TextEditingController(text: widget.visit.teethIllness);
    _illnessController = TextEditingController(text: widget.visit.illness);
    _whatWasDoneController = TextEditingController(text: widget.visit.whatWasDone);
    _totalUsdController = TextEditingController(text: widget.visit.totalUsd.toStringAsFixed(0));
    _paidUsdController = TextEditingController(text: widget.visit.paidUsd.toStringAsFixed(0));
    _rawImages = [];
    _existingImageNames = List.from(widget.visit.imageNames);
    
    _totalUsdController.addListener(_calculateRemaining);
    _paidUsdController.addListener(_calculateRemaining);
    _checkExistingTotal();
  }

  @override
  void dispose() {
    _totalUsdController.removeListener(_calculateRemaining);
    _paidUsdController.removeListener(_calculateRemaining);
    _teethIllnessController.dispose();
    _illnessController.dispose();
    _whatWasDoneController.dispose();
    _totalUsdController.dispose();
    _paidUsdController.dispose();
    super.dispose();
  }

  void _calculateRemaining() => setState(() {});

  void _checkExistingTotal() {
    final hasTotal = widget.currentCase.visits.any((v) => v.totalUsd > 0);
    setState(() {
      _hasExistingTotal = hasTotal;
      if (hasTotal) {
        final firstTotal = widget.currentCase.visits.firstWhere((v) => v.totalUsd > 0).totalUsd;
        _totalMessage = 'if you changed total cost value it will be updated for ALL visits in this case.';
        _totalMessageColor = Colors.orange.shade700;
      } else {
        _totalMessage = 'This will be the total USD for all visits in this case.';
        _totalMessageColor = Colors.green.shade700;
      }
    });
  }

  double _getRemainingBalance() {
    final total = double.tryParse(_totalUsdController.text) ?? 0.0;
    final paid = double.tryParse(_paidUsdController.text) ?? 0.0;
    return total - paid;
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    for (final xFile in picked) {
      final bytes = await xFile.readAsBytes();
      _rawImages.add(bytes);
    }
    setState(() {});
  }

  void _removeExistingImage(int index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('Are you sure you want to remove this image?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.of(context).pop();
              final imageName = _existingImageNames[index];
              await _deleteExistingImage(imageName);
              setState(() => _existingImageNames.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _removeNewImage(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('Are you sure you want to remove this image?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _rawImages.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image removed')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _copyImagesToDisk() async {
    final imgDir = PatientsStorage.imgDir;
    final savedNames = <String>[];
    for (int i = 0; i < _rawImages.length; i++) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final file = File('${imgDir.path}/$fileName');
      await file.writeAsBytes(_rawImages[i], flush: true);
      savedNames.add(fileName);
    }
    return savedNames;
  }

  Future<void> _deleteExistingImage(String imageName) async {
    try {
      final imgDir = PatientsStorage.imgDir;
      final file = File('${imgDir.path}/$imageName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  void _toggleEditMode() {
    setState(() => _isEditMode = !_isEditMode);
    if (!_isEditMode) {
      // Reset when exiting edit mode
      _visitDate = DateTime.parse(widget.visit.date);
      _teethIllnessController.text = widget.visit.teethIllness;
      _illnessController.text = widget.visit.illness;
      _whatWasDoneController.text = widget.visit.whatWasDone;
      _totalUsdController.text = widget.visit.totalUsd.toStringAsFixed(0);
      _paidUsdController.text = widget.visit.paidUsd.toStringAsFixed(0);
      _rawImages.clear();
      _existingImageNames = List.from(widget.visit.imageNames);
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final total = double.tryParse(_totalUsdController.text) ?? 0.0;
    final paid = double.tryParse(_paidUsdController.text) ?? 0.0;

    if (paid > total && total > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount paid cannot be greater than total!')),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final newImageNames = await _copyImagesToDisk();
    final allImageNames = [..._existingImageNames, ...newImageNames];

    final updatedVisit = Visit(
      id: widget.visit.id,
      patientId: widget.visit.patientId,
      caseId: widget.visit.caseId,
      date: DateFormat('yyyy-MM-dd').format(_visitDate),
      illness: _illnessController.text.trim(),
      teethIllness: _teethIllnessController.text.trim(),
      whatWasDone: _whatWasDoneController.text.trim(),
      totalUsd: total,
      paidUsd: paid,
      remainingUsd: total - paid,
      imageNames: allImageNames,
      createdAt: widget.visit.createdAt,
      updatedAt: now,
    );

    // Update existing visits with new total if changed
    final updatedVisits = widget.currentCase.visits.map((oldVisit) {
      if (oldVisit.id == widget.visit.id) {
        return updatedVisit;
      }
      if (total > 0 && widget.visit.totalUsd != total) {
        return Visit(
          id: oldVisit.id,
          patientId: oldVisit.patientId,
          caseId: oldVisit.caseId,
          date: oldVisit.date,
          illness: oldVisit.illness,
          teethIllness: oldVisit.teethIllness,
          whatWasDone: oldVisit.whatWasDone,
          totalUsd: total,
          paidUsd: oldVisit.paidUsd,
          remainingUsd: total - oldVisit.paidUsd,
          imageNames: oldVisit.imageNames,
          createdAt: oldVisit.createdAt,
          updatedAt: now,
        );
      }
      return oldVisit;
    }).toList();

    final updatedCase = Case(
      id: widget.currentCase.id,
      patientId: widget.currentCase.patientId,
      title: widget.currentCase.title,
      caseDate: widget.currentCase.caseDate,
      status: widget.currentCase.status,
      notes: widget.currentCase.notes,
      createdAt: widget.currentCase.createdAt,
      updatedAt: now,
      visits: updatedVisits,
    );

    widget.onVisitUpdated(updatedCase);
    
    setState(() {
      _isEditMode = false;
      _rawImages.clear();
      _existingImageNames = List.from(allImageNames);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visit updated successfully')),
    );
  }

  void _deleteVisit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Visit?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Delete all images
              for (final imageName in widget.visit.imageNames) {
                await _deleteExistingImage(imageName);
              }

              final updatedCase = Case(
                id: widget.currentCase.id,
                patientId: widget.currentCase.patientId,
                title: widget.currentCase.title,
                caseDate: widget.currentCase.caseDate,
                status: widget.currentCase.status,
                notes: widget.currentCase.notes,
                createdAt: widget.currentCase.createdAt,
                updatedAt: DateTime.now().toIso8601String(),
                visits: widget.currentCase.visits.where((v) => v.id != widget.visit.id).toList(),
              );

              widget.onVisitUpdated(updatedCase);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit deleted')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        title: const Text(
          'Visit Details',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _isEditMode ? Colors.blue.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isEditMode ? Icons.visibility : Icons.edit,
                color: _isEditMode ? Colors.blue : Colors.amber,
              ),
              onPressed: _toggleEditMode,
              tooltip: _isEditMode ? 'View' : 'Edit',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteVisit,
              tooltip: 'Delete',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            color: const Color(0xFF667EEA),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_open, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.currentCase.title,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.patient.name}${widget.patient.phone.isNotEmpty ? ' • ${widget.patient.phone}' : ''}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              icon: Icons.calendar_today,
              title: 'Visit Information',
              children: [
                _buildDatePicker(),
                const SizedBox(height: 16),
                _buildTextField('Teeth Illness', _teethIllnessController, maxLines: 3, readOnly: !_isEditMode),
                const SizedBox(height: 16),
                _buildTextField('Other Illnesses / Complaint', _illnessController, maxLines: 3, readOnly: !_isEditMode),
                const SizedBox(height: 16),
                _buildTextField('Treatment / What Was Done', _whatWasDoneController, maxLines: 4, readOnly: !_isEditMode),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.attach_money,
              title: 'Payment Information',
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCurrencyField('Total Cost (USD)', _totalUsdController, readOnly: !_isEditMode)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCurrencyField('Amount Paid (USD)', _paidUsdController, readOnly: !_isEditMode)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRemainingBalanceField(),
                const SizedBox(height: 12),
                if (_totalUsdController.text.isNotEmpty)
                  Text(_totalMessage, style: TextStyle(fontSize: 13, color: _totalMessageColor, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.image,
              title: 'Visit Images',
              children: [
                if (_isEditMode)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFAFA),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cloud_upload_outlined, size: 50, color: Color(0xFF667EEA)),
                            SizedBox(height: 12),
                            Text('Click to upload or drag & drop', style: TextStyle(color: Color(0xFF7F8C8D))),
                            Text('PNG, JPG, JPEG', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_existingImageNames.isNotEmpty || _rawImages.isNotEmpty) ...[
                  if (_existingImageNames.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingImageNames.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File('${PatientsStorage.imgDir.path}/${_existingImageNames[i]}')),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (_isEditMode)
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                onPressed: () => _removeExistingImage(i),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_rawImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('New Images', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _rawImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(image: MemoryImage(_rawImages[i]), fit: BoxFit.cover),
                              ),
                            ),
                            if (_isEditMode)
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                onPressed: () => _removeNewImage(i),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
                if (_existingImageNames.isEmpty && _rawImages.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No images',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            if (_isEditMode)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleEditMode,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: const Color(0xFF667EEA).withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFF667EEA)), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)))]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _isEditMode
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _visitDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) setState(() => _visitDate = date);
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Visit Date',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabled: _isEditMode,
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_visitDate)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF8F9FA) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCurrencyField(String label, TextEditingController controller, {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'USD ',
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F8C8D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: readOnly,
        fillColor: readOnly ? const Color(0xFFF8F9FA) : null,
      ),
    );
  }

  Widget _buildRemainingBalanceField() {
    final remaining = _getRemainingBalance();
    final isNegative = remaining < 0;
    
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Remaining Balance',
        prefixText: 'USD ',
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F8C8D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      controller: TextEditingController(text: remaining.toStringAsFixed(2)),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isNegative ? Colors.red : Colors.green,
      ),
    );
  }
}