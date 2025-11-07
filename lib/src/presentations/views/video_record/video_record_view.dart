import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/presentations/views/video_record/video_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../camera_picker.dart';
import '../../../core/models/camera_config.dart';
import '../../viewmodels/camera_size_notifier.dart';
import '../../viewmodels/camera_viewmodel.dart';
import '../camera_view.dart';

class VideoRecordView extends StatefulWidget {
  const VideoRecordView({
    super.key,
    required this.cameras,
    required this.config,
    this.onRecorded,
  });

  final List<CameraDescription> cameras;
  final VideoConfig config;
  final ValueChanged<File?>? onRecorded;

  @override
  State<VideoRecordView> createState() => _VideoRecordViewState();
}

class _VideoRecordViewState extends State<VideoRecordView> {
  final ValueNotifier<File?> _videoFile = ValueNotifier(null);
  late CameraSizeNotifier _notifier;
  Size? _size;
  CameraDescription? _camera;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = CameraViewModel.of(context);
    if (_size != _notifier.size) {
      _size = _notifier.size;
    }
  }

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
          action: CameraAction.videoRecord,
          cameras: widget.cameras,
          initCamera: _camera,
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
