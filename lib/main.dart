import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import './extensions/widget_extensions.dart';

const title = 'Camera / Photo Library Demo';

Future<void> navigateTo(BuildContext context, Widget page) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => page),
  );
}

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
  final _picker = ImagePicker();
  XFile? _selectedXFile;

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
                    navigateTo(context, CameraScreen(camera: widget.camera!));
                  },
                ),
              ElevatedButton(
                child: const Text('Select Photo'),
                onPressed: pickImage,
              ),
            ],
          ).gap(10),
          if (_selectedXFile != null) Text('Name: ${_selectedXFile!.name}'),
          if (_selectedXFile != null) Image.file(File(_selectedXFile!.path)),
        ],
      ),
    );
  }

  void pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _selectedXFile = image);
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

          await navigateTo(context, PhotoScreen(selectedXFile: image.path));
        } catch (e) {
          print('error: $e');
        }
      },
    );
  }
}

class PhotoScreen extends StatelessWidget {
  final String selectedXFile;

  const PhotoScreen({required this.selectedXFile, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo')),
      // The image is stored as a file on the device.
      //TODO: Where does the image get its size?
      body: Image.file(File(selectedXFile)),
    );
  }
}
