import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashModeSwitcher extends StatelessWidget {
  const FlashModeSwitcher({
    super.key,
    this.controller,
    this.values,
    this.onSwitchFlash,
  });

  final List<FlashMode>? values;
  final CameraController? controller;
  final ValueChanged<FlashMode?>? onSwitchFlash;

  @override
  Widget build(BuildContext context) {
    if (controller == null || values == null || values!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        final flashMode = values!.firstWhere(
          (e) => e == value.flashMode,
          orElse: () => values!.first,
        );

        final isRecording = value.isRecordingVideo;
        final IconData icon = switch (flashMode) {
          FlashMode.off => Icons.flash_off,
          FlashMode.auto => Icons.flash_auto,
          FlashMode.always => Icons.flash_on,
          FlashMode.torch => Icons.highlight,
        };

        final color = isRecording ? Colors.grey : Colors.white;
        return IconButton(
          icon: AnimatedSwitcher(
            duration: Durations.medium4,
            child: Icon(icon, size: 24, color: color),
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
          onPressed: isRecording ? null : _handleSwitchFlashMode,
        );
      },
    );
  }

  Future<void> _handleSwitchFlashMode() async {
    if (controller == null || values == null || values!.isEmpty) {
      return;
    }

    int currentFlashMode = values!.indexOf(controller!.value.flashMode);
    if (currentFlashMode < 0) currentFlashMode++;

    final int nextFlashMode;
    if (currentFlashMode + 1 < values!.length) {
      nextFlashMode = currentFlashMode + 1;
    } else {
      nextFlashMode = 0;
    }

    final flashMode = values!.elementAt(nextFlashMode);
    onSwitchFlash?.call(flashMode);
  }
}
