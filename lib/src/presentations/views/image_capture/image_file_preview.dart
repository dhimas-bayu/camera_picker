import 'dart:io';

import 'package:camera_picker/src/presentations/widgets/confirm_button.dart';
import 'package:flutter/material.dart';

class ImageFilePreview extends StatelessWidget {
  const ImageFilePreview({
    super.key,
    required this.imageFile,
    this.onAccepted,
    this.onRejected,
  });
  final File imageFile;
  final VoidCallback? onRejected;
  final VoidCallback? onAccepted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: Column(
        children: [
          Expanded(child: Image.file(imageFile)),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 44.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ConfirmButton(
            action: ConfirmAction.reject,
            onAction: onRejected,
          ),
          ConfirmButton(
            action: ConfirmAction.accept,
            onAction: onRejected,
          ),
        ],
      ),
    );
  }
}
