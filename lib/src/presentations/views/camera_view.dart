import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/core/models/data_video_camera.dart';
import 'package:camera_picker/src/presentations/widgets/record_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../camera_picker.dart';
import '../../core/models/data_stream_camera.dart';
import '../../core/models/data_take_camera.dart';
import '../../core/utils/callback_wrapper.dart';
import '../widgets/camera_switcher.dart';
import '../widgets/capture_button.dart';
import '../widgets/flash_mode_switcher.dart';

typedef PreviewBuilder =
    Widget Function(BuildContext context, Size previewSize);

class CameraView extends StatefulWidget {
  CameraView({
    super.key,
    this.mode = CameraMode.takePicture,
    required this.cameras,
    this.resolutionPreset,
    this.initCamera,
    this.initFlashMode,
    this.recordingDuration,
    this.targetStreamFPS = 10,
    this.onPreviewBuilder,
    this.onSwitchCamera,
    this.onSwitchFlash,
    this.onTakePicture,
    this.onStreamCamera,
    this.onRecordVideo,
  }) : assert(
         cameras.isNotEmpty,
         "Cameras list cannot be empty.",
       );

  final CameraMode mode;
  final List<CameraDescription> cameras;
  final CameraDescription? initCamera;
  final ResolutionPreset? resolutionPreset;
  final FlashMode? initFlashMode;
  final Duration? recordingDuration;
  final int targetStreamFPS;
  final PreviewBuilder? onPreviewBuilder;
  final ValueChanged<CameraDescription?>? onSwitchCamera;
  final ValueChanged<FlashMode?>? onSwitchFlash;
  final ValueChanged<DataTakeCamera?>? onTakePicture;
  final ValueChanged<DataStreamCamera?>? onStreamCamera;
  final ValueChanged<DataVideoCamera?>? onRecordVideo;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final ValueNotifier<double> _currentExposure = ValueNotifier(0.0);

  final ValueNotifier<Offset?> _focusOffset = ValueNotifier(null);

  final ValueNotifier<double> _currentScale = ValueNotifier(1.0);

  final Map<CameraMode, List<FlashMode>> _validFlashMode = {};

  List<CameraDescription> _cameras = [];

  CameraController? _controller;

  double _minAvailableZoom = 0;

  double _maxAvailableZoom = 0;

  double _minAvailableExposureOffset = 0;

  double _maxAvailableExposureOffset = 0;

  double _baseScale = 1.0;

  double _axisX = 0.0;

  double _axisY = 0.0;

  int _pointers = 0;

  CameraDescription? _description;

  FlashMode? _flashMode;

  Duration _minProcessInterval = Duration.zero;

  DateTime? _lastProcessTime;

  DataStreamCamera _dataStreamCamera = const DataStreamCamera();

  DataTakeCamera _dataTakeCamera = const DataTakeCamera();

  DataVideoCamera _dataVideoCamera = const DataVideoCamera();

  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flashMode = widget.initFlashMode;
    _initCameras(description: widget.initCamera);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("CURRENT STATE : $state");
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initCameras(
        description: cameraController.description,
      );
    } else if (state == AppLifecycleState.inactive) {
      _disposed = true;
      cameraController.dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _currentExposure.dispose();
    _currentScale.dispose();
    _focusOffset.dispose();
    _controller?.dispose();
    _controller = null;
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("REBUILD CAMERA");
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: true,
      bottom: true,
      child: Stack(
        children: [
          _buildCameraPreview(),
          _buildCameraNavigation(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: CameraPreview(
        _controller!,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (details) async {
                    return _onViewFinderTap(details, constraints);
                  },
                ),
                ?widget.onPreviewBuilder?.call(
                  context,
                  constraints.biggest,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraNavigation() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: switch (widget.mode) {
        CameraMode.takePicture => _takePictureNavigation(),
        CameraMode.scanBarcode => _scanBarcodeNavigation(),
        CameraMode.videoRecord => _recordVideoNavigation(),
      },
    );
  }

  Widget _takePictureNavigation() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CameraSwitcher(
            controller: _controller,
            onSwitchCamera: _handleSwitchCamera,
          ),
          CaptureButton(
            controller: _controller,
            onTakePicture: _handleTakePicture,
          ),
          FlashModeSwitcher(
            controller: _controller,
            values: _validFlashMode[widget.mode],
            onSwitchFlash: _handleSwitchFlashMode,
          ),
        ],
      ),
    );
  }

  Widget _recordVideoNavigation() {
    final duration = widget.recordingDuration ?? const Duration(seconds: 10);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CameraSwitcher(
            controller: _controller,
            onSwitchCamera: _handleSwitchCamera,
          ),
          RecordButton(
            recordDuration: duration,
            controller: _controller,
            onStartRecording: _handleStartRecording,
            onStopRecording: _handleStopRecording,
          ),
          FlashModeSwitcher(
            controller: _controller,
            values: _validFlashMode[widget.mode],
            onSwitchFlash: _handleSwitchFlashMode,
          ),
        ],
      ),
    );
  }

  Widget _scanBarcodeNavigation() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 44.0,
        left: 16.0,
        right: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlashModeSwitcher(
            controller: _controller,
            values: _validFlashMode[widget.mode],
            onSwitchFlash: _handleSwitchFlashMode,
          ),
        ],
      ),
    );
  }

  Future<void> _initCameras({
    CameraDescription? description,
  }) async {
    _cameras = widget.cameras;
    _description = description ?? _cameras.first;
    if (_validFlashMode.isEmpty) _availablesFlashMode();

    ImageFormatGroup? imageFormatGroup = switch (widget.mode) {
      CameraMode.takePicture => ImageFormatGroup.jpeg,
      _ => Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
    };

    final cameraController = CameraController(
      _description!,
      widget.resolutionPreset ?? ResolutionPreset.high,
      imageFormatGroup: imageFormatGroup,
      enableAudio: false,
    );
    _controller = cameraController;
    cameraController.addListener(() {
      if (mounted) {
        _disposed = false;
        setState(() {});
      }

      if (cameraController.value.hasError) {
        debugPrint(
          'INIT CAMERA ERROR ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      if (cameraController.value.isInitialized) {
        widget.onSwitchCamera?.call(_description);
      }

      await Future.wait([
        cameraController.getMaxExposureOffset().then((value) {
          _maxAvailableExposureOffset = value;
        }),
        cameraController.getMinExposureOffset().then((value) {
          _minAvailableExposureOffset = value;
        }),
        cameraController.getMinZoomLevel().then((value) {
          _minAvailableZoom = value;
        }),
        cameraController.getMaxZoomLevel().then((value) {
          _maxAvailableZoom = value;
        }),
      ], eagerError: true);

      if (widget.mode == CameraMode.scanBarcode) {
        _minProcessInterval = Duration(
          milliseconds: (1000 / widget.targetStreamFPS).round(),
        );

        cameraController.startImageStream((image) {
          _streamImage(image, cameraController);
        });
      }
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }
  }

  void _availablesFlashMode() {
    for (final mode in CameraMode.values) {
      List<FlashMode> flashMode = switch (mode) {
        CameraMode.takePicture => FlashMode.values,
        CameraMode.scanBarcode => [FlashMode.off, FlashMode.torch],
        CameraMode.videoRecord => [FlashMode.off, FlashMode.torch],
      };

      _validFlashMode.addAll({mode: flashMode});
    }
  }

  Future<void> _streamImage(
    CameraImage image,
    CameraController controller,
  ) async {
    if (!_shouldSkipProcessing()) {
      _dataStreamCamera = _dataStreamCamera.copyWith(
        image: image,
        deviceOrientation: controller.value.deviceOrientation,
        lensDirection: controller.description.lensDirection,
        sensorOrientation: controller.description.sensorOrientation,
      );
      widget.onStreamCamera?.call(_dataStreamCamera);
    }
  }

  bool _shouldSkipProcessing() {
    if (_lastProcessTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastProcessTime!);
      if (elapsed < _minProcessInterval) {
        return true;
      }
    }

    return false;
  }

  Future<void> _handleTakePicture() async {
    await callbackWrapper<void>(
      "TAKE PICTURE",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        if (controller.value.isTakingPicture) return;

        final imageFile = await controller.takePicture();
        _dataTakeCamera = _dataTakeCamera.copyWith(
          imageFile: File(imageFile.path),
        );

        widget.onTakePicture?.call(_dataTakeCamera);
      },
    );
  }

  Future<void> _handleStartRecording() async {
    await callbackWrapper<void>(
      "START RECORDING VIDEO",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        if (controller.value.isRecordingVideo) return;
        await controller.startVideoRecording();
      },
    );
  }

  Future<void> _handleStopRecording() async {
    await callbackWrapper<void>(
      "STOP RECORDING VIDEO",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        if (!controller.value.isRecordingVideo) return;
        final videoFile = await controller.stopVideoRecording();
        _dataVideoCamera = _dataVideoCamera.copyWith(
          videoFile: File(videoFile.path),
        );

        widget.onRecordVideo?.call(_dataVideoCamera);
      },
    );
  }

  Future<void> _handleZoom(double scale) async {
    if (_maxAvailableZoom == _minAvailableZoom) return;
    final zoom = (_baseScale * scale).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );

    if (zoom == _currentScale.value) return;

    await callbackWrapper<void>(
      "SET ZOOM LEVEL",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        await controller.setZoomLevel(zoom);
        _currentScale.value = zoom;
      },
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale.value;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_pointers != 2) return;
    _handleZoom(details.scale);
  }

  Future<void> _handleFocus(Offset offset) async {
    await callbackWrapper(
      "SET FOCUS POINT",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        _focusOffset.value = offset;

        await Future.wait([
          controller.setFocusMode(FocusMode.locked),
          controller.setFocusPoint(offset),
          controller.setExposurePoint(offset),
        ]);

        Future.delayed(
          const Duration(seconds: 1),
          () => _focusOffset.value = null,
        );
      },
    );
  }

  Future<void> _onViewFinderTap(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    _axisX = details.localPosition.dx;
    _axisY = details.localPosition.dy;

    double xp = _axisX / constraints.maxWidth;
    double yp = _axisY / constraints.maxHeight;

    Offset offset = Offset(xp, yp);
    _handleFocus(offset);
  }

  Future<void> _handleSwitchCamera(CameraLensDirection? direction) async {
    await callbackWrapper(
      "SWITCH CAMERA",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        final description = _cameras.firstWhereOrNull(
          (d) => d.lensDirection == direction,
        );

        await _initCameras(description: description);
      },
    );
  }

  Future<void> _handleSwitchFlashMode(FlashMode? flashMode) async {
    if (flashMode == null) return;
    await callbackWrapper(
      "SWITCH FLASH MODE",
      isDisposed: _disposed,
      controller: _controller,
      callback: (controller) async {
        await controller.setFlashMode(flashMode);
        _flashMode = flashMode;
        widget.onSwitchFlash?.call(_flashMode);
      },
    );
  }
}
