import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  bool _isLoading = false;

  final picker = ImagePicker();

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  /// Capture image from camera
  Future<void> capturePhoto() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image: $e")),
      );
    }
  }

  /// Send image to backend for pest detection
  Future<void> detectPest() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select or capture an image first.")),
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
            builder: (context) => ResultScreen(result: result, imageFile: _image!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to detect pest. Check backend connection.")),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Pest Detection")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text("Pick from Gallery"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: capturePhoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Capture Photo"),
              ),
              const SizedBox(height: 20),
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: detectPest,
                      icon: const Icon(Icons.search),
                      label: const Text("Detect Pest"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
