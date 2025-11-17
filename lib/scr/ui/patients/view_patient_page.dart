import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../../models/models.dart';
import '../../services/image_helper.dart';

class ViewUserPage extends StatefulWidget {
  final User user;
  const ViewUserPage({super.key, required this.user});

  @override
  State<ViewUserPage> createState() => _ViewUserPageState();
}

class _ViewUserPageState extends State<ViewUserPage> {
  late int selectedIndex;
  late TextEditingController nameC,
      visitsC,
      dateC,
      teethC,
      illnessC,
      whatWasDoneC,
      totalC,
      paidC,
      remC;

  late List<Uint8List> _images;
  bool _loading = false;

  Future<void> _loadImages() async {
    setState(() => _loading = true);
    _images.clear();
    if (widget.user.visits.isNotEmpty) {
      final names = widget.user.visits[selectedIndex].imageNames;
      for (final n in names) {
        final bytes = await ImageHelper.load(n);
        if (bytes != null) _images.add(bytes);
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _openImageViewer(int initialPage) {
    if (_images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          images: _images,
          initialPage: initialPage,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
    _images = [];
    _initControllers();
    _loadImages();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final hPadding = isTablet ? 32.0 : 16.0;
          final vPadding = isTablet ? 24.0 : 16.0;
          final maxContentWidth = isTablet ? 800.0 : double.infinity;

          return Center(
            child: Container(
              width: maxContentWidth,
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
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
                                      _loadImages();
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
                          const SizedBox(height: 8),
                          _section('Photos', [
                            if (_loading)
                              const Center(child: CircularProgressIndicator())
                            else if (_images.isEmpty)
                              const Text('No images for this visit', style: TextStyle(color: Colors.grey))
                            else
                              _ImageGallery(
                                images: _images,
                                onTap: (page) => _openImageViewer(page),
                              ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
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

  Widget _field(TextEditingController c, String label, IconData icon,
      {int maxLines = 1, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        readOnly: true,
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

class _ImageGallery extends StatelessWidget {
  final List<Uint8List> images;
  final Function(int) onTap;

  const _ImageGallery({required this.images, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(i),
          child: Hero(
            tag: 'image$i',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: MemoryImage(images[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<Uint8List> images;
  final int initialPage;

  const _FullScreenImageViewer({required this.images, this.initialPage = 0});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.toDouble();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _currentPage = i.toDouble()),
            itemBuilder: (_, i) => Center(
              child: Hero(
                tag: 'image$i',
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.memory(widget.images[i], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              left: 8,
              top: MediaQuery.of(context).size.height * 0.5 - 24,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white, size: 40),
                onPressed: () {
                  if (_currentPage > 0) _pageController.previousPage(duration: 200.ms, curve: Curves.easeOut);
                },
              ),
            ),
          if (widget.images.length > 1)
            Positioned(
              right: 8,
              top: MediaQuery.of(context).size.height * 0.5 - 24,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                onPressed: () {
                  if (_currentPage < widget.images.length - 1) _pageController.nextPage(duration: 200.ms, curve: Curves.easeOut);
                },
              ),
            ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: DotsIndicator(
                  dotsCount: widget.images.length,
                  position: _currentPage.toInt(),
                  decorator: DotsDecorator(
                    size: const Size.square(8.0),
                    activeSize: const Size(20.0, 8.0),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    color: Colors.white38,
                    activeColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension _DurationExt on int {
  Duration get ms => Duration(milliseconds: this);
}