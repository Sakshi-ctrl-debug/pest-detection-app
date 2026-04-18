import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/animated_button.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  final File imageFile;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _scanController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  int _boxCount() {
    final confidence = widget.result['confidence'].toDouble();
    if (confidence >= 90) return 12;
    if (confidence >= 80) return 10;
    if (confidence >= 70) return 8;
    if (confidence >= 60) return 6;
    return 4;
  }

  List<Widget> _drawBoxes(Size size) {
    int count = _boxCount();
    List<Widget> widgets = [];

    for (int i = 0; i < count; i++) {
      double left = _random.nextDouble() * (size.width - 90);
      double top =
          size.height * 0.2 + _random.nextDouble() * (size.height * 0.5);

      widgets.add(
        Positioned(
          left: left,
          top: top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.greenAccent,
                child: Text(
                  widget.result['pest'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.greenAccent, width: 2),
                ),
              ),
            ],
          ),
        ),
      );

      // Heatmap blob per box
      widgets.add(
        Positioned(
          left: left - 20,
          top: top - 20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.red.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _scanner(Size size) {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (_, __) {
        final scanHeight = size.height * 0.6;
        final start = size.height * 0.2;

        return Positioned(
          top: start + scanHeight * _scanController.value,
          left: 0,
          right: 0,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.greenAccent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _imageCard(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pest = widget.result['pest'];
    final confidence = widget.result['confidence'];
    final info = widget.result['info'];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Detection Result',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.bug_report,
                      size: 30,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detected Pest',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$pest',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Confidence: ${confidence.toString()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.green.shade50.withOpacity(0.3),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Pest Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('Status', '$pest detected'),
                        const SizedBox(height: 12),
                        _infoRow('Confidence', '${confidence.toString()}%'),
                        const SizedBox(height: 12),
                        if (info is String)
                          Text(
                            info,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Damage', info['damage'] ?? 'N/A'),
                              const SizedBox(height: 12),
                              _infoRow('Prevention', info['prevention'] ?? 'N/A'),
                              const SizedBox(height: 12),
                              _infoRow('Treatment', info['treatment'] ?? 'N/A'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 8),
                  Text('Scan Another Image'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
