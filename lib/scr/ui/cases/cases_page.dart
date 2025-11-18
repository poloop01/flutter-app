import 'package:flutter/material.dart';
import '../../models/patients.dart';
import 'case_modal.dart';
import 'visit_page.dart';           // ← our visits page
import 'package:intl/intl.dart';     // ← ADD THIS FOR DateFormat

class CasesPage extends StatefulWidget {
  final Patient patient;
  final ValueChanged<Patient>? onPatientUpdated;

  const CasesPage({
    required this.patient,
    this.onPatientUpdated,
    super.key,
  });

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  late Patient patient;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
  }

  // ──────────────────────────────────────────────────────────────
  //  C A S E S   C R U D
  // ──────────────────────────────────────────────────────────────
  Future<void> _addCase(
    String title,
    String caseDate,
    String status,
    String notes,
    String createdAt,
    String updatedAt,
  ) async {
    final newCase = Case(
      patientId: patient.id,
      title: title,
      caseDate: caseDate,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    setState(() {
      patient = Patient(
        id: patient.id,
        name: patient.name,
        phone: patient.phone,
        createdAt: patient.createdAt,
        updatedAt: patient.updatedAt,
        cases: [...patient.cases, newCase],
      );
    });

    widget.onPatientUpdated?.call(patient);
    _showCoolSnackBar('Case "${newCase.title}" added');
  }

  Future<void> _updateCase(
    Case oldCase,
    String title,
    String caseDate,
    String status,
    String notes,
    String createdAt,
    String updatedAt,
  ) async {
    final index = patient.cases.indexWhere((c) => c.id == oldCase.id);
    if (index != -1) {
      final updatedCase = Case(
        id: oldCase.id,
        patientId: patient.id,
        title: title,
        caseDate: caseDate,
        status: status,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        visits: oldCase.visits,
      );

      final updatedCases = List<Case>.from(patient.cases)..[index] = updatedCase;

      setState(() {
        // ← Fixed: no copyWith needed → just rebuild the Patient object
        patient = Patient(
          id: patient.id,
          name: patient.name,
          phone: patient.phone,
          createdAt: patient.createdAt,
          updatedAt: patient.updatedAt,
          cases: updatedCases,
        );
      });

      widget.onPatientUpdated?.call(patient);
      _showCoolSnackBar('Case updated');
    }
  }

  Future<void> _deleteCase(Case caseToDelete) async {
    setState(() {
      patient = Patient(
        id: patient.id,
        name: patient.name,
        phone: patient.phone,
        createdAt: patient.createdAt,
        updatedAt: patient.updatedAt,
        cases: patient.cases.where((c) => c.id != caseToDelete.id).toList(),
      );
    });
    widget.onPatientUpdated?.call(patient);
    _showCoolSnackBar('Case deleted');
  }

  // ──────────────────────────────────────────────────────────────
  //  N A V I G A T I O N   T O   V I S I T S
  // ──────────────────────────────────────────────────────────────
  void _openVisitsPage(Case currentCase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitPage(
          patient: patient,
          currentCase: currentCase,
          onCaseUpdated: (updatedCase) {
            // Update the case locally when visits are added/edited
            setState(() {
              final index = patient.cases.indexWhere((c) => c.id == updatedCase.id);
              if (index != -1) {
                final newCases = List<Case>.from(patient.cases);
                newCases[index] = updatedCase;
                patient = Patient(
                  id: patient.id,
                  name: patient.name,
                  phone: patient.phone,
                  createdAt: patient.createdAt,
                  updatedAt: patient.updatedAt,
                  cases: newCases,
                );
              }
            });
            widget.onPatientUpdated?.call(patient);
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  M O D A L S
  // ──────────────────────────────────────────────────────────────
  Future<void> _showAddCaseModal() async {
    final result = await showDialog<(String, String, String, String, String, String)>(
      context: context,
      builder: (_) => const AddCaseModal(),
    );
    if (result == null) return;
    final (title, caseDate, status, notes, createdAt, updatedAt) = result;
    await _addCase(title, caseDate, status, notes, createdAt, updatedAt);
  }

  Future<void> _showEditCaseModal(Case caseToEdit) async {
    final result = await showDialog<(String, String, String, String, String, String)>(
      context: context,
      builder: (_) => EditCaseModal(caseData: caseToEdit),
    );
    if (result == null) return;
    final (title, caseDate, status, notes, createdAt, updatedAt) = result;
    await _updateCase(caseToEdit, title, caseDate, status, notes, createdAt, updatedAt);
  }

  void _showDeleteConfirmation(Case caseToDelete) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Case?'),
        content: const Text('This will also delete all visits.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCase(caseToDelete);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCoolSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(msg))]),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  B U I L D
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filteredCases = patient.cases.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.notes.toLowerCase().contains(q) ||
          c.caseDate.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('${patient.name} - Cases', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade900,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCaseModal,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Add Case'),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search cases, dates, or notes...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // List
          Expanded(
            child: filteredCases.isEmpty
                ? const Center(child: Text('No cases yet', style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredCases.length,
                    itemBuilder: (_, i) {
                      final c = filteredCases[i];
                      final isOpen = c.status == 'open';

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(22),
                          shadowColor: (isOpen ? Colors.blue : Colors.green).withOpacity(0.25),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _openVisitsPage(c),   // ← Tap card → VisitPage
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isOpen
                                      ? [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.4)]
                                      : [Colors.green.shade50, Colors.green.shade100.withOpacity(0.4)],
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isOpen ? Colors.blue : Colors.green,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [BoxShadow(color: (isOpen ? Colors.blue : Colors.green).withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6))],
                                    ),
                                    child: Icon(isOpen ? Icons.folder_open_rounded : Icons.task_alt_rounded, color: Colors.white, size: 36),
                                  ),
                                  const SizedBox(width: 18),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
                                        const SizedBox(height: 8),
                                        Row(children: [
                                          const Icon(Icons.event_available, size: 16, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(DateFormat('dd MMM yyyy').format(DateTime.parse(c.caseDate)),
                                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                        ]),
                                        if (c.notes.trim().isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            const Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text(c.notes.trim(), style: const TextStyle(fontSize: 13.5, color: Colors.grey), maxLines: 3, overflow: TextOverflow.ellipsis)),
                                          ]),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Status + Menu
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(color: isOpen ? Colors.blue : Colors.green, borderRadius: BorderRadius.circular(30)),
                                        child: Text(isOpen ? 'OPEN' : 'DONE',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ),
                                      const SizedBox(height: 16),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        onSelected: (v) {
                                          if (v == 'visits') _openVisitsPage(c);
                                          if (v == 'edit') _showEditCaseModal(c);
                                          if (v == 'delete') _showDeleteConfirmation(c);
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(value: 'visits', child: Row(children: [Icon(Icons.remove_red_eye_outlined), SizedBox(width: 12), Text('View Visits')])),
                                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 12), Text('Edit Case')])),
                                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 12), Text('Delete Case', style: TextStyle(color: Colors.red))])),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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