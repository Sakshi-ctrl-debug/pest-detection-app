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
    final confidence = (widget.result['confidence'] ?? 0).toDouble();
    if (confidence >= 90) return 12;
    if (confidence >= 80) return 10;
    if (confidence >= 70) return 8;
    if (confidence >= 60) return 6;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final pest = widget.result['pest'] ?? "Unknown Pest";
    final confidence = widget.result['confidence'] ?? 0;

    final info = widget.result['info'] ?? {};
    final marathiName = info['मराठी नाव'] ?? 'No data available';

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

            // RESULT CARD
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
                          pest.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "मराठी नाव: $marathiName",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
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

            // IMAGE
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

            // INFO CARD
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pest Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _infoRow('मराठी नाव', marathiName),
                  const SizedBox(height: 12),

                  _infoRow('Damage', info['damage'] ?? 'No data available'),
                  const SizedBox(height: 12),

                  _infoRow('Prevention', info['prevention'] ?? 'No data available'),
                  const SizedBox(height: 12),

                  _infoRow('Treatment', info['treatment'] ?? 'No data available'),
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
          width: 100,
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
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
