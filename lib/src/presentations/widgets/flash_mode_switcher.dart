import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashModeSwitcher extends StatelessWidget {
  const FlashModeSwitcher({super.key, this.controller, this.onSwitchFlash});
  final CameraController? controller;
  final ValueChanged<FlashMode?>? onSwitchFlash;

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox.shrink();

    return IconButton(
      icon: ValueListenableBuilder<CameraValue>(
        valueListenable: controller!,
        builder: (context, value, child) {
          final flashMode = value.flashMode;
          final icon = switch (flashMode) {
            FlashMode.off => Icons.flash_off,
            FlashMode.auto => Icons.flash_auto,
            FlashMode.always => Icons.flash_on,
            FlashMode.torch => Icons.highlight,
          };
          return AnimatedSwitcher(
            duration: Durations.medium4,
            child: Icon(icon, size: 24, color: Colors.white),
          );
        },
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white38,
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        fixedSize: const Size.square(48.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: _handleSwitchFlashMode,
    );
  }

  Future<void> _handleSwitchFlashMode() async {
    final flashMode = switch (controller?.value.flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
      _ => null,
    };

    onSwitchFlash?.call(flashMode);
  }
}
