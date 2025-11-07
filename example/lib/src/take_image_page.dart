import 'dart:io';

import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

class TakeImagePage extends StatelessWidget {
  const TakeImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    File? imageFile;
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageFile != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.file(imageFile!),
                ),
              ),
            FilledButton.icon(
              onPressed: () async {
                imageFile = await CameraPicker.takePicture(context);
                setState(() {});
              },
              label: Text("Take Image"),
            ),
          ],
        ),
      ),
    );
  }
}
