import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import './extensions/widget_extensions.dart';

const title = 'Camera / Photo Library Demo';

Future<void> main() async {
  runApp(
    MaterialApp(
      theme: ThemeData.light(),
      title: title,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

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
              ElevatedButton(
                child: const Text('Take Photo'),
                onPressed: takePhoto,
              ),
              ElevatedButton(
                child: const Text('Select Photo'),
                onPressed: pickImage,
              ),
            ],
          ).gap(10),
          //if (_selectedXFile != null) Text('Name: ${_selectedXFile!.name}'),
          if (_selectedXFile != null)
            //Image(image: FileImage(File(_selectedXFile!.path))),
            CircleAvatar(
              backgroundImage: FileImage(File(_selectedXFile!.path)),
              radius: 100,
            ),
        ],
      ),
    );
  }

  void pickImage() async {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() => _selectedXFile = image);
  }

  void takePhoto() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() => _selectedXFile = image);
  }
}
