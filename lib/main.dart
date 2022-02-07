import 'dart:async';
import 'dart:io' show File;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './extensions/widget_extensions.dart';

const title = 'Camera / Photo Library Demo';

Future<void> main() async {
  // Ensure that plugin services are initialized so
  // availableCameras can be called before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Get a list of the available cameras on the device.
  // This might include front and rear facing cameras.
  final cameras = await availableCameras();

  final firstCamera = cameras.isEmpty ? null : cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      title: title,
      home: Home(camera: firstCamera),
    ),
  );
}

class Home extends StatefulWidget {
  final CameraDescription? camera;

  Home({required this.camera, Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? imageFilePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(title)),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.camera == null) const Text('No camera found.'),
              if (widget.camera != null)
                ElevatedButton(
                  child: const Text('Take Photo'),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                          builder: (_) => CameraScreen(camera: widget.camera!)),
                    )
                        .then((filePath) {
                      setState(() => imageFilePath = filePath);
                    });
                  },
                ),
            ],
          ).gap(10),
          if (imageFilePath != null) Image.file(File(imageFilePath!)),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({required this.camera, Key? key}) : super(key: key);

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      // Wait until the controller is initialized
      // before displaying the camera preview.
      // FutureBuilder is used here to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? CameraPreview(_controller)
              : const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      child: const Icon(Icons.camera_alt),
      onPressed: () async {
        try {
          // Wait for the camera to be initialized.
          await _initializeControllerFuture;

          final image = await _controller.takePicture();

          Navigator.pop(context, image.path);
        } catch (e) {
          print('error: $e');
        }
      },
    );
  }
}
