import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/core/utils/overlay_size_utils.dart';
import 'package:flutter/widgets.dart';

import '../../../../camera_picker.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/models/camera_config.dart';
import '../camera_view.dart';
import 'image_file_preview.dart';

class ImageCaptureView extends StatefulWidget {
  const ImageCaptureView({
    super.key,
    required this.cameras,
    required this.config,
    this.onTakePicture,
  });
  final List<CameraDescription> cameras;
  final CameraConfig config;
  final ValueChanged<File?>? onTakePicture;

  @override
  State<ImageCaptureView> createState() => _ImageCaptureViewState();
}

class _ImageCaptureViewState extends State<ImageCaptureView> {
  final ValueNotifier<File?> _imageFile = ValueNotifier(null);
  Size? _layoutSize;
  Rect? _boundingBox;
  CameraDescription? _camera;
  FlashMode? _flashMode;

  @override
  void dispose() {
    _imageFile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _imageFile,
      builder: (context, value, child) {
        if (value != null) {
          return ImageFilePreview(
            imageFile: value,
            onRejected: () {
              if (value.existsSync()) {
                value.deleteSync();
                _imageFile.value = null;
              }
            },
            onAccepted: () {
              widget.onTakePicture?.call(value);
            },
          );
        }

        return CameraView(
          mode: CameraMode.takePicture,
          cameras: widget.cameras,
          initCamera: _camera,
          initFlashMode: _flashMode,
          onPreviewBuilder: _buildOverlay,
          onSwitchCamera: (description) {
            _camera = description;
          },
          onSwitchFlash: (flashMode) {
            _flashMode = flashMode;
          },
          onTakePicture: (dataCamera) async {
            File? resultFile = dataCamera?.imageFile;
            if (resultFile != null &&
                widget.config.autoCropping &&
                _boundingBox != null &&
                _layoutSize != null) {
              final imageBytes = await resultFile.readAsBytes();
              resultFile = await ImageUtils.cropImageFromFile(
                imageBytes: imageBytes,
                screenRect: _boundingBox!,
                displaySize: _layoutSize!,
                quality: widget.config.quality,
                flippedHorizontal:
                    _camera?.lensDirection == CameraLensDirection.front,
              );
            }
            _imageFile.value = resultFile;
          },
        );
      },
    );
  }

  Widget _buildOverlay(BuildContext context, Size size) {
    _layoutSize = size;
    final center = Offset(size.width / 2, size.height / 2);
    final docSize = OverlaySizeUtils.getSize(
      widget.config.overlayType ?? OverlayType.ktp,
    );
    final overlaySize = docSize.toOverlaySize(size, scaleFactor: .8);
    _boundingBox = Rect.fromCenter(
      center: center,
      width: overlaySize.width,
      height: overlaySize.height,
    );

    return CustomPaint(
      size: size,
      painter: CameraOverlayPainter(
        boundingBox: _boundingBox,
        radius: const Radius.circular(8.0),
      ),
    );
  }
}
