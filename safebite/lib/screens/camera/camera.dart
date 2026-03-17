import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'result_screen.dart';
import '../../models/prediction_result.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      _image = file;
    });

    final result = _mockPrediction();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          image: file,
          result: result,
        ),
      ),
    );
  }

  PredictionResult _mockPrediction() {
    return PredictionResult(
      label: "Burger",
      confidence: 0.92,
      allergens: ["Gluten", "Dairy"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Food")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Capture Image"),
        ),
      ),
    );
  }
}
