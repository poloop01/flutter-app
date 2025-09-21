import 'package:flutter/material.dart';
import '../models/models.dart';

class ViewUserPage extends StatefulWidget {
  final User user;
  const ViewUserPage({super.key, required this.user});

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  late int selectedIndex;
  late TextEditingController nameC, visitsC, dateC, teethC, illnessC, whatWasDoneC, totalC, paidC, remC;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _initControllers();
  }

  void _initControllers() {
    nameC = TextEditingController(text: widget.user.name);
    visitsC = TextEditingController(text: widget.user.visits.length.toString());
    if (widget.user.visits.isEmpty) {
      dateC = TextEditingController();
      teethC = TextEditingController();
      illnessC = TextEditingController();
      whatWasDoneC = TextEditingController();
      totalC = TextEditingController();
      paidC = TextEditingController();
      remC = TextEditingController();
    } else {
      final v = widget.user.visits[selectedIndex];
      dateC = TextEditingController(text: v.date);
      teethC = TextEditingController(text: v.teethIllness);
      illnessC = TextEditingController(text: v.illness);
      whatWasDoneC = TextEditingController(text: v.whatWasDone);
      totalC = TextEditingController(text: v.totalUSD.toString());
      paidC = TextEditingController(text: v.paidUSD.toString());
      remC = TextEditingController(text: v.remainingUSD.toStringAsFixed(2));
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    visitsC.dispose();
    dateC.dispose();
    teethC.dispose();
    illnessC.dispose();
    whatWasDoneC.dispose();
    totalC.dispose();
    paidC.dispose();
    remC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.visits.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.user.name)),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.schedule_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No visits recorded yet', style: TextStyle(color: Colors.grey.shade600)),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: Text(widget.user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButton<int>(
                        value: selectedIndex + 1,
                        isExpanded: true,
                        items: List.generate(
                          widget.user.visits.length,
                          (i) => DropdownMenuItem(value: i + 1, child: Text('Record ${i + 1}')),
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
                    _field(nameC, 'Name', Icons.person),
                    _field(visitsC, 'Number of Visits', Icons.visibility),
                    _field(dateC, 'Date', Icons.calendar_today),
                    const SizedBox(height: 8),
                    _visitCounterCard(),
                    const SizedBox(height: 8),
                    _field(teethC, 'Teeth Illness', Icons.medical_services, maxLines: 5),
                    _field(illnessC, 'Other Illnesses', Icons.local_hospital, maxLines: 5),
                    _field(whatWasDoneC, 'Treatment Description', Icons.healing, maxLines: 5),
                  ]),
                  const SizedBox(height: 8),
                  _section('Financial Information', [
                    _field(totalC, 'Total USD', Icons.account_balance_wallet, labelColor: Colors.blue),
                    _field(paidC, 'Paid USD', Icons.check_circle, labelColor: Colors.green),
                    _field(remC, 'Remaining USD', Icons.pending, labelColor: Colors.orange),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* ----------------  HELPERS  ---------------- */
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

  Widget _visitCounterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.indigo.shade300, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(.3),
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

  Widget _field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        readOnly: true, // ← read-only but no grey disable
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor ?? Colors.grey.shade600),
          prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
        ),
      ),
    );
  }
}