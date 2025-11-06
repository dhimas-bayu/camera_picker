import 'dart:io';

import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<File?> _imageFile = ValueNotifier(null);

  @override
  void dispose() {
    _imageFile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera picker app'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: _imageFile,
          builder: (context, file, child) {
            return file == null
                ? SizedBox.shrink()
                : ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(16.0),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(file),
                  );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              style: FilledButton.styleFrom(fixedSize: Size.fromHeight(56.0)),
              icon: Icon(Icons.qr_code_outlined),
              label: Text("Scan QR-CODE"),
              onPressed: () async {
                await CameraPicker.scanBarcode(context);
              },
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(fixedSize: Size.fromHeight(56.0)),
              icon: Icon(Icons.camera_rounded),
              label: Text("Take Image"),
              onPressed: () async {
                final imageFile = await CameraPicker.takePicture(context);
                _imageFile.value = imageFile;
              },
            ),
          ],
        ),
      ),
    );
  }
}
