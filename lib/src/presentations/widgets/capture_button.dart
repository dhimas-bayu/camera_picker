import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key, this.controller, this.onTakePicture});
  final CameraController? controller;
  final VoidCallback? onTakePicture;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTakePicture,
      child: ValueListenableBuilder(
        valueListenable: controller!,
        builder: (context, value, child) {
          final isTakingPicture = value.isTakingPicture;
          return Container(
            width: 72.0,
            height: 72.0,
            decoration: const ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(width: 4.0, color: Colors.white),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: Durations.short4,
                  width: 48.0,
                  height: 48.0,
                  margin: isTakingPicture
                      ? const EdgeInsets.all(8.0)
                      : const EdgeInsets.all(2.0),
                  decoration: const ShapeDecoration(
                    color: Colors.white,
                    shape: CircleBorder(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
