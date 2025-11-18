import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/patients.dart';
import 'add_visit.dart';

class VisitPage extends StatefulWidget {
  final Patient patient;
  final Case currentCase;
  final ValueChanged<Case> onCaseUpdated;

  const VisitPage({
    required this.patient,
    required this.currentCase,
    required this.onCaseUpdated,
    super.key,
  });

  @override
  State<VisitPage> createState() => _VisitPageState();
}

class _VisitPageState extends State<VisitPage> {
  late Case currentCase;

  @override
  void initState() {
    super.initState();
    currentCase = widget.currentCase;
  }

  void _openAddVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVisitPage(
          patient: widget.patient,
          currentCase: currentCase,
          onVisitAdded: (updatedCase) {
            setState(() => currentCase = updatedCase);
            widget.onCaseUpdated(updatedCase);
          },
        ),
      ),
    );
  }

  double get totalPaid => currentCase.visits.fold(0.0, (sum, v) => sum + v.paidUsd);
  double get totalUsd => currentCase.visits.isEmpty ? 0.0 : currentCase.visits.first.totalUsd;
  double get remainingUsd => totalUsd - totalPaid;

  @override
  Widget build(BuildContext context) {
    final hasVisits = currentCase.visits.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(currentCase.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.person, size: 16), const SizedBox(width: 6), Text(widget.patient.name, style: const TextStyle(color: Colors.white70, fontSize: 14))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.phone, size: 14), const SizedBox(width: 6), Text(widget.patient.phone, style: const TextStyle(color: Colors.white70, fontSize: 13))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.event, size: 14), const SizedBox(width: 6), Text('Case: ${DateFormat('dd MMM yyyy').format(DateTime.parse(currentCase.caseDate))}', style: const TextStyle(color: Colors.white70, fontSize: 13))]),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddVisit,
        backgroundColor: const Color(0xFF667EEA),
        icon: const Icon(Icons.add),
        label: const Text('Add Visit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: hasVisits
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Summary Card
                  Container(
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
                          Text('\$${totalUsd.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ]),
                        Column(children: [
                          const Text('Paid', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('\$${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Remaining', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('\$${remainingUsd.toStringAsFixed(0)}', style: TextStyle(color: remainingUsd > 0 ? Colors.orange : Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Visits List
                  ...currentCase.visits.map((visit) => _buildVisitCard(visit)).toList(),
                ],
              )
            : ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 90, color: Colors.grey[400]),
                        const SizedBox(height: 24),
                        Text('No visits yet', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.grey[700])),
                        const SizedBox(height: 12),
                        Text('Tap the + button to add the first visit', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date only (no paid badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF667EEA),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(DateTime.parse(visit.date)), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.sick, 'Illness', visit.illness.isEmpty ? '–' : visit.illness),
                const SizedBox(height: 12),
                _infoRow(Icons.coronavirus, 'Teeth Issue', visit.teethIllness.isEmpty ? '–' : visit.teethIllness),
                const SizedBox(height: 16),
                // single line money info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: \$${visit.totalUsd.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Paid: \$${visit.paidUsd.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('Remaining: \$${visit.remainingUsd.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w600, color: visit.remainingUsd > 0 ? Colors.orange : Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}