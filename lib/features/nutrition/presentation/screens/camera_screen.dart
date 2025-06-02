import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  bool _isMounted = false; // To track mounted state for async operations

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (_isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found on this device.')),
          );
          setState(() => _isReady = false); // Explicitly set to false if no cameras
        }
        return;
      }

      // Initialize controller with the first camera
      _controller = CameraController(
        _cameras![0], // Use the first available camera
        ResolutionPreset.high,
        enableAudio: false, // Audio is not needed for snapping meal pictures
      );

      await _controller!.initialize();

      if (_isMounted) {
        setState(() {
          _isReady = true;
        });
      }
    } on CameraException catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: ${e.description}')),
        );
        setState(() => _isReady = false);
      }
      print('Error initializing camera: $e');
    } catch (e) {
      if (_isMounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
        setState(() => _isReady = false);
      }
      print('Unexpected error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera when the app is resumed
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _isMounted = false;
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not ready.')),
      );
      return;
    }
    if (_controller!.value.isTakingPicture) {
      return; // A capture is already pending, do nothing.
    }

    try {
      final XFile imageFile = await _controller!.takePicture();
      if (_isMounted) {
        // Pop screen and return the image path
        Navigator.of(context).pop(imageFile.path);
      }
    } on CameraException catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: ${e.description}')),
        );
      }
      print('Error taking picture: $e');
    } catch (e) {
       if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred while taking picture: ${e.toString()}')),
        );
      }
      print('Unexpected error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Snap Meal')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Snap Meal')),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_controller!),
          // Optional: Add overlay for crop guides, etc.
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
