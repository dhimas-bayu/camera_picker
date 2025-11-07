import 'dart:io';

import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';

class RecordVideoPage extends StatelessWidget {
  const RecordVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    File? videoFile;
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (videoFile != null) Expanded(child: Text("${videoFile?.path}")),
            FilledButton.icon(
              onPressed: () async {
                videoFile = await CameraPicker.videoRecord(context);
                setState(() {});
              },
              label: Text("Record Video"),
            ),
          ],
        ),
      ),
    );
  }
}
