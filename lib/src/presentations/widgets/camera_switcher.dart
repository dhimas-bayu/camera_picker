import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraSwitcher extends StatelessWidget {
  const CameraSwitcher({super.key, this.controller, this.onSwitchCamera});
  final CameraController? controller;
  final ValueChanged<CameraLensDirection?>? onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        final isRecording = value.isRecordingVideo;
        final lensDirection = value.description.lensDirection;
        final turn = lensDirection == CameraLensDirection.front ? 45.0 : 90.0;
        final color = isRecording ? Colors.grey : Colors.white;

        return IconButton(
          icon: AnimatedRotation(
            duration: Durations.medium4,
            turns: degreesToRadians(turn),
            child: Icon(Icons.cached_rounded, color: color),
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            side: BorderSide(color: color),
            fixedSize: const Size.square(48.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: isRecording ? null : _handleSwitchCamera,
        );
      },
    );
  }

  Future<void> _handleSwitchCamera() async {
    CameraDescription? description = controller?.description;
    if (description != null) {
      final direction = description.lensDirection;
      if (direction == CameraLensDirection.back) {
        onSwitchCamera?.call(CameraLensDirection.front);
      } else {
        onSwitchCamera?.call(CameraLensDirection.back);
      }
    }
  }

  double degreesToRadians(double degrees) {
    return (degrees * (math.pi / 180));
  }
}
