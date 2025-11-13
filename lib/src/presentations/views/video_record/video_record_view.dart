import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/presentations/views/video_record/video_preview.dart';
import 'package:flutter/material.dart';

import '../../../../camera_picker.dart';
import '../camera_view.dart';

class VideoRecordView extends StatefulWidget {
  const VideoRecordView({
    super.key,
    required this.cameras,
    required this.config,
    this.onRecorded,
  });

  final List<CameraDescription> cameras;
  final CameraVideoConfig config;
  final ValueChanged<File?>? onRecorded;

  @override
  State<VideoRecordView> createState() => _VideoRecordViewState();
}

class _VideoRecordViewState extends State<VideoRecordView> {
  final ValueNotifier<File?> _videoFile = ValueNotifier(null);
  CameraDescription? _camera;
  FlashMode? _flashMode;

  @override
  void dispose() {
    _videoFile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _videoFile,
      builder: (context, value, child) {
        if (value != null) {
          return VideoPreview(
            videoFile: value,
            onRejected: () {
              if (value.existsSync()) {
                value.deleteSync();
                _videoFile.value = null;
              }
            },
            onAccepted: () {
              widget.onRecorded?.call(value);
            },
          );
        }

        return CameraView(
          mode: CameraMode.videoRecord,
          cameras: widget.cameras,
          resolutionPreset: widget.config.resolutionPreset,
          initCamera: _camera,
          initFlashMode: _flashMode ?? FlashMode.off,
          onSwitchCamera: (value) {
            _camera = value;
          },
          onSwitchFlash: (value) {
            _flashMode = value;
          },
          onRecordVideo: (value) {
            Future.delayed(Durations.medium2, () {
              _videoFile.value = value?.videoFile;
            });
          },
        );
      },
    );
  }
}
