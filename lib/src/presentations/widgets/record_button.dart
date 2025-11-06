import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  const RecordButton({super.key, this.controller, this.onTakePicture});
  final CameraController? controller;
  final VoidCallback? onTakePicture;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        final isRecording = value.isRecordingVideo;
        final color = isRecording ? Colors.red : Colors.white;

        return IconButton.outlined(
          icon: AnimatedContainer(
            duration: Durations.short4,
            decoration: ShapeDecoration(
              color: color,
              shape: const CircleBorder(),
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: color,
            side: BorderSide(color: color),
            fixedSize: const Size.square(64.0),
          ),
          onPressed: onTakePicture,
        );
      },
    );
  }
}
