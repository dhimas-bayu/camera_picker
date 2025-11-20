import 'dart:io';

import 'package:camera_picker/camera_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class RecordVideoPage extends StatelessWidget {
  const RecordVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    File? videoFile;
    int? videoSize;

    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 16.0,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Card.filled(
                clipBehavior: Clip.antiAlias,
                child: videoFile != null && videoSize != null
                    ? Center(
                        child: Text(
                          getStats(videoFile!, videoSize!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : SizedBox.expand(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  fixedSize: Size(double.maxFinite, 56.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                onPressed: () async {
                  videoFile = await CameraPicker.videoRecord(
                    context,
                    config: CameraVideoConfig(
                      duration: 10000, // in milliseconds
                      resolutionPreset: ResolutionPreset.high,
                    ),
                  );
                  if (videoFile != null) {
                    videoSize = videoFile!.lengthSync();
                  }
                  setState(() {});
                },
                child: Text("Record Video"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getStats(File file, int size) {
    return """
    {
      'file_name': "${basename(file.path)}",
      'file_size': "${(size ~/ (1024 * 1024)).toStringAsFixed(2)} MB",
    }""";
  }
}
