import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart' as cam;

import 'result_screen.dart';
import '../../models/prediction_result.dart';

class Camera extends StatefulWidget {
  final List<cam.CameraDescription> cameras;

  const Camera({
    super.key,
    required this.cameras,
  });

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera>
    with AutomaticKeepAliveClientMixin<Camera> {
  cam.CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    // ✅ find back camera
    final backCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == cam.CameraLensDirection.back,
      orElse: () => widget.cameras.first,
    );

    final controller = cam.CameraController(
      backCamera,
      cam.ResolutionPreset.high,
      enableAudio: false,
    );

    _controller = controller;
    _initializeControllerFuture = controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || _isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      await _initializeControllerFuture;

      final cam.XFile file = await _controller!.takePicture();
      final imageFile = File(file.path);

      final results = _mockPredictions();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: imageFile,
            results: results,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to capture image.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      final imageFile = File(file.path);
      final results = _mockPredictions();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            image: imageFile,
            results: results,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to pick image from gallery.');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  List<PredictionResult> _mockPredictions() {
    return [
      PredictionResult(
        label: 'Burger',
        confidence: 0.92,
        allergens: ['Gluten', 'Dairy'],
      ),
      PredictionResult(
        label: 'Fries',
        confidence: 0.88,
        allergens: [],
      ),
    ];
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.cameras.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No camera found on this device.'),
        ),
      );
    }

    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              controller != null &&
              controller.value.isInitialized) {
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.previewSize!.height,
                          height: controller.value.previewSize!.width,
                          child: cam.CameraPreview(controller),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isProcessing)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _pickFromGallery,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _captureImage,
                            child: Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: const Center(
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 56),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to initialize camera.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }
}
