/*
// TEMP DISABLED
import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'package:flutter/services.dart';

class TFLiteService {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  static Future<void> initialize() async {
    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('assets/models/pest_model.tflite');

      // Load labels
      final labelsData = await rootBundle.loadString('assets/models/class_names.json');
      _labels = List<String>.from(json.decode(labelsData));

      print('✅ TFLite model loaded successfully');
    } catch (e) {
      print('❌ Failed to load TFLite model: $e');
    }
  }

  static Future<Map<String, dynamic>?> detectPestOnDevice(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      print('❌ TFLite not initialized');
      return null;
    }

    try {
      // Read and preprocess image
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      // Resize to 224x224
      img.Image resized = img.copyResize(image, width: 224, height: 224);

      // Convert to float32 array [1, 224, 224, 3]
      var input = Float32List(1 * 224 * 224 * 3);
      var index = 0;

      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          var pixel = resized.getPixel(x, y);
          input[index++] = img.getRed(pixel) / 255.0;
          input[index++] = img.getGreen(pixel) / 255.0;
          input[index++] = img.getBlue(pixel) / 255.0;
        }
      }

      // Prepare output buffer
      var output = Float32List(1 * _labels!.length);

      // Run inference
      _interpreter!.run(input, output);

      // Get results
      var maxIndex = 0;
      var maxConfidence = output[0];
      for (var i = 1; i < output.length; i++) {
        if (output[i] > maxConfidence) {
          maxConfidence = output[i];
          maxIndex = i;
        }
      }

      var confidence = maxConfidence * 100;

      return {
        'pest': _labels![maxIndex],
        'confidence': confidence.roundToDouble(),
        'info': 'On-device detection - no network required!'
      };

    } catch (e) {
      print('❌ On-device inference failed: $e');
      return null;
    }
  }

  static void dispose() {
    _interpreter?.close();
  }
}
*/