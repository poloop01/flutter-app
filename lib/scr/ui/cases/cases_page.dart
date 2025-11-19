import 'package:flutter/material.dart';
import '../../models/patients.dart';
import 'case_modal.dart';
import '../visits/visit_page.dart';
import 'package:intl/intl.dart';
import '../../services/image_helper.dart';

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
      patient = patient.copyWith(cases: [...patient.cases, newCase]);
    });

    widget.onPatientUpdated?.call(patient);
    _showCoolSnackBar('Case "$title" added');
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
    final updatedCase = Case(
      id: oldCase.id,
      patientId: oldCase.patientId,
      title: title,
      caseDate: caseDate,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      visits: oldCase.visits,
    );

    final updatedCases = patient.cases.map((c) => c.id == oldCase.id ? updatedCase : c).toList();

    setState(() {
      patient = patient.copyWith(cases: updatedCases);
    });

    widget.onPatientUpdated?.call(patient);
    _showCoolSnackBar('Case updated');
  }

  Future<void> _deleteCase(Case caseToDelete) async {
    int deletedImageCount = 0;
    final Set<String> allImageNames = {};

    for (final visit in caseToDelete.visits) {
      if (visit.imageNames.isNotEmpty) {
        allImageNames.addAll(visit.imageNames);
      }
    }

    for (final imageName in allImageNames) {
      try {
        await ImageHelper.delete(imageName);
        deletedImageCount++;
      } catch (e) {
        debugPrint('Failed to delete image: $imageName → $e');
      }
    }

    setState(() {
      patient = patient.copyWith(
        cases: patient.cases.where((c) => c.id != caseToDelete.id).toList(),
      );
    });

    widget.onPatientUpdated?.call(patient);

    String msg = 'Case deleted';
    if (deletedImageCount > 0) {
      msg += ' • $deletedImageCount photo${deletedImageCount == 1 ? '' : 's'} removed';
    }
    _showCoolSnackBar(msg);
  }

  void _openVisitsPage(Case currentCase) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitPage(
          patient: patient,
          currentCase: currentCase,
          onCaseUpdated: (updatedCase) {
            setState(() {
              final updatedCases = patient.cases.map((c) => c.id == updatedCase.id ? updatedCase : c).toList();
              patient = patient.copyWith(cases: updatedCases);
            });
            widget.onPatientUpdated?.call(patient);
          },
        ),
      ),
    );
  }

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
    final visitCount = caseToDelete.visits.length;
    final totalImages = caseToDelete.visits.fold<int>(0, (sum, v) => sum + v.imageNames.length);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Case?'),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'This action is permanent.\n\n'),
              TextSpan(text: '• $visitCount visit${visitCount == 1 ? '' : 's'}\n', style: const TextStyle(fontWeight: FontWeight.w600)),
              if (totalImages > 0)
                TextSpan(
                  text: '• $totalImages photo${totalImages == 1 ? '' : 's'} will be deleted',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pop(context);
              _deleteCase(caseToDelete);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red.shade700),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showCoolSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  FINANCIAL SUMMARY
  // ──────────────────────────────────────────────────────────────
  Map<String, double> getGlobalSummary() {
    double total = 0.0, paid = 0.0, remaining = 0.0;
    for (final c in patient.cases) {
      if (c.visits.isEmpty) continue;
      total += c.visits.first.totalUsd;
      for (final v in c.visits) {
        paid += v.paidUsd;
        remaining += v.remainingUsd;
      }
    }
    return {'total': total, 'paid': paid, 'remaining': remaining};
  }

  Map<String, double> getCaseSummary(Case c) {
    if (c.visits.isEmpty) return {'total': 0.0, 'paid': 0.0, 'remaining': 0.0};
    final first = c.visits.first;
    double paid = 0.0, rem = 0.0;
    for (final v in c.visits) {
      paid += v.paidUsd;
      rem += v.remainingUsd;
    }
    return {'total': first.totalUsd, 'paid': paid, 'remaining': rem};
  }

  @override
  Widget build(BuildContext context) {
    final filteredCases = patient.cases.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.notes.toLowerCase().contains(q) ||
          c.caseDate.contains(q);
    }).toList();

    final global = getGlobalSummary();
    final hasGlobalData = global['total']! > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${patient.name} - Cases', style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade900,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCaseModal,
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Case', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
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

          // Global Financial Summary – EXACT SAME DESIGN AS VISIT PAGE
          if (hasGlobalData)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Cost', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('\$${global['total']!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ]),
                    Column(children: [
                      const Text('Paid', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('\$${global['paid']!.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Remaining', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(
                        '\$${global['remaining']!.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: global['remaining']! > 0 ? Colors.orange : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

          // Cases List
          Expanded(
            child: filteredCases.isEmpty
                ? const Center(child: Text('No cases yet', style: TextStyle(fontSize: 18, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredCases.length,
                    itemBuilder: (_, i) {
                      final c = filteredCases[i];
                      final isOpen = c.status == 'open';
                      final caseSum = getCaseSummary(c);
                      final hasCaseData = caseSum['total']! > 0;

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
                            onTap: () => _openVisitsPage(c),
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
                              child: Column(
                                children: [
                                  // Main Content
                                  Row(
                                    children: [
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
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            const SizedBox(height: 8),
                                            Row(children: [
                                              const Icon(Icons.event_available, size: 16, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(DateFormat('dd MMM yyyy').format(DateTime.parse(c.caseDate)), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                                            ]),
                                            if (c.notes.trim().isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                const Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(c.notes.trim(), style: const TextStyle(fontSize: 13.5, color: Colors.grey), maxLines: 3, overflow: TextOverflow.ellipsis),
                                                ),
                                              ]),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(color: isOpen ? Colors.blue : Colors.green, borderRadius: BorderRadius.circular(30)),
                                            child: Text(isOpen ? 'OPEN' : 'DONE', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

                                  // Case Financial Summary (Minimal, Bottom)
                                  if (hasCaseData) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildMinimalChip('Total', caseSum['total']!, Colors.blue.shade100),
                                          _buildMinimalChip('Paid', caseSum['paid']!, Colors.green.shade100),
                                          _buildMinimalChip('Remaining', caseSum['remaining']!, caseSum['remaining']! > 0 ? Colors.orange.shade100 : Colors.grey.shade300),
                                        ],
                                      ),
                                    ),
                                  ],
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

  // Minimal chip for case cards
  Widget _buildMinimalChip(String label, double amount, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}