import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key, this.controller, this.onTakePicture});
  final CameraController? controller;
  final VoidCallback? onTakePicture;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return IconButton(
      icon: ValueListenableBuilder<CameraValue>(
        valueListenable: controller!,
        builder: (context, value, child) {
          final isTakingPicture = value.isTakingPicture;
          return AnimatedContainer(
            duration: Durations.short4,
            margin: isTakingPicture
                ? const EdgeInsets.all(4.0)
                : EdgeInsets.zero,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: CircleBorder(),
            ),
          );
        },
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white38,
        foregroundColor: Colors.white,
        // side: const BorderSide(color: Colors.white),
        fixedSize: const Size.square(72.0),
      ),
      onPressed: onTakePicture,
    );
  }
}
