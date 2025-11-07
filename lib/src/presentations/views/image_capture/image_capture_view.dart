import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/core/utils/overlay_size_utils.dart';
import 'package:flutter/widgets.dart';

import '../../../../camera_picker.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/models/camera_config.dart';
import '../../viewmodels/camera_size_notifier.dart';
import '../../viewmodels/camera_viewmodel.dart';
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
  late CameraSizeNotifier _notifier;
  Size? _size;
  Rect? _boundingBox;
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
          action: CameraAction.takePicture,
          cameras: widget.cameras,
          initCamera: _camera,
          overlay: _overlay(),
          onTakePicture: (dataCamera) async {
            File? resultFile = dataCamera?.imageFile;
            if (resultFile != null &&
                widget.config.autoCropping &&
                _boundingBox != null &&
                _size != null) {
              final imageBytes = await resultFile.readAsBytes();
              resultFile = await ImageUtils.cropImageFromFile(
                imageBytes: imageBytes,
                screenRect: _boundingBox!,
                displaySize: _size!,
                quality: widget.config.quality,
                flippedHorizontal:
                    dataCamera?.lensDirection == CameraLensDirection.front,
              );
            }

            _camera = widget.cameras.firstWhere((e) {
              return e.lensDirection == dataCamera?.lensDirection;
            });

            _imageFile.value = resultFile;
          },
        );
      },
    );
  }

  Widget? _overlay() {
    if (_size == null) return null;
    final center = Offset(_size!.width / 2, _size!.height / 2);
    final docSize = OverlaySizeUtils.getSize(
      widget.config.overlayType ?? OverlayType.ktp,
    );
    final overlaySize = docSize.toOverlaySize(_size!, scaleFactor: .8);
    _boundingBox = Rect.fromCenter(
      center: center,
      width: overlaySize.width,
      height: overlaySize.height,
    );

    return CustomPaint(
      size: _size!,
      painter: CameraOverlayPainter(
        boundingBox: _boundingBox,
        radius: const Radius.circular(8.0),
      ),
    );
  }
}
