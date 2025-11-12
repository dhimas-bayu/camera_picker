import 'dart:io';

import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

class TakeImagePage extends StatefulWidget {
  const TakeImagePage({super.key});

  @override
  State<TakeImagePage> createState() => _TakeImagePageState();
}

class _TakeImagePageState extends State<TakeImagePage> {
  File? _imageFile;
  String? _imageSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Card.filled(
                    clipBehavior: Clip.antiAlias,
                    child: _imageFile != null
                        ? Image.file(_imageFile!)
                        : SizedBox.expand(),
                  ),
                ),

                Text("File size : ${_imageSize ?? "-"}"),
              ],
            ),
          ),
          Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.8,
              children: [
                MaterialButton(
                  elevation: 0,
                  color: Color(0xff6398a9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () async {
                    final file = await CameraPicker.takePicture(
                      context,
                      config: CameraPickerConfig(
                        showOverlay: false,
                        autoCropping: false,
                        quality: 100,
                      ),
                    );
                    if (file != null) setResult(file);
                  },
                  child: Text(
                    "No Compression",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  elevation: 0,
                  color: Color(0xff96c7b3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () async {
                    final file = await CameraPicker.takePicture(
                      context,
                      config: CameraPickerConfig(
                        showOverlay: false,
                        autoCropping: false,
                        quality: 80,
                      ),
                    );
                    if (file != null) setResult(file);
                  },
                  child: Text(
                    "With Compression",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  elevation: 0,
                  color: Color(0xfff9b95c),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () async {
                    final file = await CameraPicker.takePicture(
                      context,
                      config: CameraPickerConfig(
                        showOverlay: true,
                        overlaySize: OverlaySize.paperA4(),
                        autoCropping: true,
                        quality: 100,
                      ),
                    );

                    if (file != null) setResult(file);
                  },
                  child: Text(
                    "Cropping no compression",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  elevation: 0,
                  color: Color(0xffd7897f),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onPressed: () async {
                    final file = await CameraPicker.takePicture(
                      context,
                      config: CameraPickerConfig(
                        showOverlay: true,
                        overlaySize: OverlaySize.paperA4(),
                        autoCropping: true,
                        quality: 80,
                      ),
                    );

                    if (file != null) setResult(file);
                  },
                  child: Text(
                    "Cropping with compression",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> setResult(File file) async {
    final bytes = await file.length();
    final sizeMB = bytes ~/ 1024;
    _imageFile = file;
    _imageSize = ("${sizeMB.toStringAsFixed(2)} KB");

    setState(() {});
  }
}
