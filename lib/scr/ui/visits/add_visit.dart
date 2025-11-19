import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/patients.dart';
import '../../storage/patients_storage.dart'; // ← gives us the ready-made folder

class AddVisitPage extends StatefulWidget {
  final Patient patient;
  final Case currentCase;
  final Function(Case updatedCase) onVisitAdded;

  const AddVisitPage({
    required this.patient,
    required this.currentCase,
    required this.onVisitAdded,
    super.key,
  });

  @override
  State<AddVisitPage> createState() => _AddVisitPageState();
}

class _AddVisitPageState extends State<AddVisitPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _visitDate = DateTime.now();
  final _illnessController = TextEditingController();
  final _teethIllnessController = TextEditingController();
  final _whatWasDoneController = TextEditingController();
  final _totalUsdController = TextEditingController();
  final _paidUsdController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _rawImages = []; // RAM bytes

  bool _hasExistingTotal = false;
  String _totalMessage = '';
  Color _totalMessageColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _checkExistingTotal();
    // Listen to changes on total and paid fields
    _totalUsdController.addListener(_calculateRemaining);
    _paidUsdController.addListener(_calculateRemaining);
  }

  @override
  void dispose() {
    _totalUsdController.removeListener(_calculateRemaining);
    _paidUsdController.removeListener(_calculateRemaining);
    _illnessController.dispose();
    _teethIllnessController.dispose();
    _whatWasDoneController.dispose();
    _totalUsdController.dispose();
    _paidUsdController.dispose();
    super.dispose();
  }

  /* ----------------------------------------------------------
   *              F I N A N C E   L O G I C
   * --------------------------------------------------------*/
  void _checkExistingTotal() {
    final hasTotal = widget.currentCase.visits.any((v) => v.totalUsd > 0);
    setState(() {
      _hasExistingTotal = hasTotal;
      if (hasTotal) {
        final firstTotal = widget.currentCase.visits.firstWhere((v) => v.totalUsd > 0).totalUsd;
        _totalUsdController.text = firstTotal.toStringAsFixed(0);
        _totalMessage = 'if you changed total cost value it will be updated for ALL visits in this case.';
        _totalMessageColor = Colors.orange.shade700;
      } else {
        _totalMessage = 'This will be the total USD for all visits in this case.';
        _totalMessageColor = Colors.green.shade700;
      }
    });
    _calculateRemaining();
  }

  void _calculateRemaining() => setState(() {});

  double _getRemainingBalance() {
    final total = double.tryParse(_totalUsdController.text) ?? 0.0;
    final paid = double.tryParse(_paidUsdController.text) ?? 0.0;
    return total - paid;
  }

  /* ----------------------------------------------------------
   *              I M A G E   H A N D L I N G
   * --------------------------------------------------------*/
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    for (final xFile in picked) {
      final bytes = await xFile.readAsBytes();
      _rawImages.add(bytes);
    }
    setState(() {});
  }

  void _removeImage(int index) => setState(() => _rawImages.removeAt(index));

  /// Writes bytes into the SAME folder that PatientsStorage created.
  Future<List<String>> _copyImagesToDisk() async {
    final imgDir = PatientsStorage.imgDir; // ← already exists
    final savedNames = <String>[];
    for (int i = 0; i < _rawImages.length; i++) {
      final fileName = '${const Uuid().v4()}.jpg';
      final file = File('${imgDir.path}/$fileName');
      await file.writeAsBytes(_rawImages[i], flush: true);
      savedNames.add(fileName);
    }
    return savedNames;
  }

  /* ----------------------------------------------------------
   *                      S A V E
   * --------------------------------------------------------*/
  void _saveVisit() async {
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
    final imageNames = await _copyImagesToDisk(); // ← bytes now persisted

    final newVisit = Visit(
      id: const Uuid().v4(),
      patientId: widget.patient.id,
      caseId: widget.currentCase.id,
      date: DateFormat('yyyy-MM-dd').format(_visitDate),
      illness: _illnessController.text.trim(),
      teethIllness: _teethIllnessController.text.trim(),
      whatWasDone: _whatWasDoneController.text.trim(),
      totalUsd: total,
      paidUsd: paid,
      remainingUsd: total - paid,
      imageNames: imageNames,
      createdAt: now,
      updatedAt: now,
    );

    // update existing visits with new total (same behaviour as before)
    final updatedVisits = widget.currentCase.visits.map((oldVisit) {
      if (total > 0) {
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

    final finalVisits = [...updatedVisits, newVisit];
    final updatedCase = Case(
      id: widget.currentCase.id,
      patientId: widget.currentCase.patientId,
      title: widget.currentCase.title,
      caseDate: widget.currentCase.caseDate,
      status: widget.currentCase.status,
      notes: widget.currentCase.notes,
      createdAt: widget.currentCase.createdAt,
      updatedAt: now,
      visits: finalVisits,
    );

    widget.onVisitAdded(updatedCase);
    Navigator.pop(context);
  }

  /* ----------------------------------------------------------
   *                      U I
   * --------------------------------------------------------*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        title: const Text(
          'Add New Visit',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                _buildTextField('Teeth Illness', _teethIllnessController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('Other Illnesses / Complaint', _illnessController, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('Treatment / What Was Done', _whatWasDoneController, maxLines: 4),
              ],
            ),
            const SizedBox(height: 20),

            _buildSection(
              icon: Icons.attach_money,
              title: 'Payment Information',
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCurrencyField('Total Cost (USD)', _totalUsdController, isRequired: false)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCurrencyField('Amount Paid (USD)', _paidUsdController, isRequired: false)),
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
                if (_rawImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                            onPressed: () => _removeImage(i),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveVisit,
                icon: const Icon(Icons.save),
                label: const Text('Save Visit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 10,
                  shadowColor: const Color(0xFF667EEA).withOpacity(0.5),
                ),
              ),
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
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _visitDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) setState(() => _visitDate = date);
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Visit Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(_visitDate)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCurrencyField(String label, TextEditingController controller, {bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'USD ',
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7F8C8D)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: isRequired ? (v) => v != null && v.isEmpty ? 'Required' : null : null,
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