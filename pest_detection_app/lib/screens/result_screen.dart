import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text("AI Pest Detection")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _imageCard(
              "Uploaded Image",
              Image.file(widget.imageFile),
            ),

            const SizedBox(height: 20),

            _imageCard(
              "AI Analyzed Image",
              LayoutBuilder(
                builder: (context, constraints) {
                  final size =
                      Size(constraints.maxWidth, constraints.maxWidth);

                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Stack(
                      children: [
                        Image.file(widget.imageFile,
                            width: size.width,
                            height: size.height,
                            fit: BoxFit.cover),
                        ..._drawBoxes(size),
                        _scanner(size),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.bug_report, color: Colors.green),
                title: const Text("Detected Pest"),
                subtitle: Text("$pest ($confidence%)"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Damage"),
                subtitle: Text(widget.result['info']['damage']),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Prevention"),
                subtitle: Text(widget.result['info']['prevention']),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Treatment"),
                subtitle: Text(widget.result['info']['treatment']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
