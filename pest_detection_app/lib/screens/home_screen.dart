import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/animated_button.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLoading = false;

  final picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> capturePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> detectPest() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.detectPest(_image!);

      setState(() => _isLoading = false);

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: result,
              imageFile: _image!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to detect pest. Check backend.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3FBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // 🔹 HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bug_report,
                        color: Colors.green, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pest Detection',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Upload insect/pest image to identify pests.\nकिडीचा/किटकाचा फोटो अपलोड करा.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🔹 IMAGE SELECTION CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [

                    const Text(
                      'Choose Image',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 Instruction (EN + MR)
                    const Text(
                      'Upload insect image \nफक्त किडीचा फोटो अपलोड करा',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🟢 GALLERY BUTTON
                    AnimatedButton(
                      onPressed: pickImageFromGallery,
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Pick from Gallery\nगॅलरीतून निवडा',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🟢 CAMERA BUTTON
                    AnimatedButton(
                      onPressed: capturePhoto,
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Capture Photo\nफोटो काढा',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 IMAGE PREVIEW
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Text(
                          'No image selected\nकाही फोटो निवडलेला नाही',
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // 🔹 DETECT BUTTON
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnimatedButton(
                      onPressed: detectPest,
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text('Detect Pest / किड अथवा किटक ओळखा'),
                    ),

              const SizedBox(height: 16),

              // 🔹 TIP
              Text(
                'Tip: Use clear insect image for better detection.\nटिप: किडीचा/किटकाचा स्पष्ट फोटो वापरा.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}