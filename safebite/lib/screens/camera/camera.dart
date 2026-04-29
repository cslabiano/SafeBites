import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart' as cam;

import 'result_screen.dart';
import '../../services/food_detector_service.dart';

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
  final FoodDetectorService _detector = FoodDetectorService();

  bool _isFlashOn = false;
  bool _isProcessing = false;
  bool _isModelLoading = true;
  String? _modelError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;

      await _controller!.setFlashMode(
        _isFlashOn ? cam.FlashMode.torch : cam.FlashMode.off,
      );

      if (mounted) setState(() {});
    } catch (e) {
      _showError('Flash is not available on this device.');
    }
  }

  Future<void> _initializeAll() async {
    await Future.wait([
      _initializeCamera(),
      _loadModel(),
    ]);
  }

  Future<void> _loadModel() async {
    try {
      await _detector.loadModel();
    } catch (e) {
      if (mounted) {
        setState(() {
          _modelError = 'Failed to load model: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isModelLoading = false;
        });
      }
    }
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;

    final backCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == cam.CameraLensDirection.back,
      orElse: () => widget.cameras.first,
    );

    final controller = cam.CameraController(
      backCamera,
      cam.ResolutionPreset.medium,
      enableAudio: false,
    );

    _controller = controller;
    _initializeControllerFuture = controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || _isProcessing || _isModelLoading) return;
    if (_modelError != null) {
      _showError(_modelError!);
      return;
    }

    try {
      setState(() => _isProcessing = true);
      await _initializeControllerFuture;
      final cam.XFile file = await _controller!.takePicture();
      await _runPrediction(File(file.path));
    } catch (e) {
      _showError('Failed to capture image: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing || _isModelLoading) return;
    if (_modelError != null) {
      _showError(_modelError!);
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      await _runPrediction(File(file.path));
    } catch (e) {
      _showError('Failed to pick image from gallery: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _runPrediction(File imageFile) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Analyzing...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 100));

    FoodDetectionOutput output;

    try {
      output = await _detector.predict(imageFile);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showError('Prediction failed: $e');
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ResultScreen(
                image: imageFile,
                results: output.results,
                annotatedImageBytes: output.annotatedImageBytes,
                maskPngBytes: output.maskPngBytes,
              )),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller?.setFlashMode(cam.FlashMode.off);
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.cameras.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No camera found on this device.')),
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
                // Camera preview
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

                // Model error banner
                if (_modelError != null)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _modelError!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                // Bottom controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isModelLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                'Loading model...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
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
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: _toggleFlash,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                                  color:
                                      _isFlashOn ? Colors.yellow : Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
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
