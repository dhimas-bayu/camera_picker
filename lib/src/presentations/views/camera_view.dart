import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_picker/src/core/models/data_video_camera.dart';
import 'package:camera_picker/src/presentations/widgets/record_button.dart';
import '../../core/models/data_stream_camera.dart';
import '../../core/models/data_take_camera.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../../../camera_picker.dart';
import '../widgets/camera_switcher.dart';
import '../widgets/capture_button.dart';
import '../widgets/flash_mode_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

import '../../core/utils/callback_wrapper.dart';

class CameraView extends StatefulWidget {
  CameraView({
    super.key,
    this.action = CameraAction.takePicture,
    required this.cameras,
    this.initCamera,
    this.overlay,
    this.recordingDuration,
    this.targetStreamFPS = 10,
    this.onTakePicture,
    this.onStreamCamera,
    this.onRecordVideo,
  }) : assert(
         cameras.isNotEmpty,
         "Cameras list cannot be empty.",
       );

  final CameraAction action;
  final List<CameraDescription> cameras;
  final CameraDescription? initCamera;
  final Widget? overlay;
  final Duration? recordingDuration;
  final int targetStreamFPS;
  final ValueChanged<DataTakeCamera?>? onTakePicture;
  final ValueChanged<DataStreamCamera?>? onStreamCamera;
  final ValueChanged<DataVideoCamera?>? onRecordVideo;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _initNotifier = ValueNotifier(false);

  final ValueNotifier<double> _currentExposure = ValueNotifier(0.0);

  final ValueNotifier<Offset?> _focusOffset = ValueNotifier(null);

  final ValueNotifier<double> _currentScale = ValueNotifier(1.0);

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

  Size? _previewSize;

  CameraDescription? _description;

  Duration _minProcessInterval = Duration.zero;

  DateTime? _lastProcessTime;

  DataStreamCamera _dataStreamCamera = const DataStreamCamera();

  DataTakeCamera _dataTakeCamera = const DataTakeCamera();

  DataVideoCamera _dataVideoCamera = const DataVideoCamera();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera(description: widget.initCamera);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("CURRENT STATE : $state");
  }

  @override
  void dispose() {
    _currentExposure.dispose();
    _currentScale.dispose();
    _focusOffset.dispose();
    _initNotifier.dispose();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();
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
            final notifier = CameraViewModel.maybeOf(context);

            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            _previewSize = Size(width, height);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              notifier?.setPreviewSize(constraints.biggest);
            });

            return Stack(
              children: [
                ?widget.overlay,
                GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (details) async {
                    return _onViewFinderTap(details, constraints);
                  },
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
      child: switch (widget.action) {
        CameraAction.takePicture => _takePictureNavigation(),
        CameraAction.scanBarcode => _scanBarcodeNavigation(),
        CameraAction.videoRecord => _recordVideoNavigation(),
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
            onSwitchFlash: _handleSwitchFlashMode,
          ),
        ],
      ),
    );
  }

  Widget _recordVideoNavigation() {
    final duration = widget.recordingDuration ?? const Duration(seconds: 10);

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, left: 16.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RecordButton(
            recordDuration: duration,
            controller: _controller,
            onStartRecording: _handleStartRecording,
            onStopRecording: _handleStopRecording,
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
            onSwitchFlash: _handleSwitchFlashMode,
          ),
        ],
      ),
    );
  }

  Future<void> _initCamera({
    CameraDescription? description,
  }) async {
    _cameras = widget.cameras;
    _description = description ?? _cameras.first;

    ImageFormatGroup? imageFormatGroup = switch (widget.action) {
      CameraAction.takePicture => ImageFormatGroup.jpeg,
      _ => Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    };

    final cameraController = CameraController(
      _description!,
      ResolutionPreset.high,
      imageFormatGroup: imageFormatGroup,
      enableAudio: false,
    );

    _controller = cameraController;
    cameraController.addListener(() {
      if (mounted) setState(() {});

      if (cameraController.value.hasError) {
        debugPrint(
          'INIT CAMERA ERROR ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      _initNotifier.value = cameraController.value.isInitialized;

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
      ]);

      if (mounted && widget.action == CameraAction.scanBarcode) {
        _minProcessInterval = Duration(
          milliseconds: (1000 / widget.targetStreamFPS).round(),
        );

        await cameraController.startImageStream((image) {
          _streamImage(image, cameraController);
        });
      }
    } on CameraException catch (e) {
      debugPrint(e.toString());
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
      controller: _controller,
      callback: (controller) async {
        if (controller.value.isTakingPicture) return;

        final imageFile = await controller.takePicture();
        _dataTakeCamera = _dataTakeCamera.copyWith(
          lensDirection: controller.description.lensDirection,
          imageFile: File(imageFile.path),
        );

        widget.onTakePicture?.call(_dataTakeCamera);
      },
    );
  }

  Future<void> _handleStartRecording() async {
    await callbackWrapper<void>(
      "START RECORDING VIDEO",
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
      controller: _controller,
      callback: (controller) async {
        final description = _cameras.firstWhereOrNull(
          (d) => d.lensDirection == direction,
        );

        await _initCamera(description: description);
      },
    );
  }

  Future<void> _handleSwitchFlashMode(FlashMode? flashMode) async {
    if (flashMode == null) return;
    await callbackWrapper(
      "SWITCH FLASH MODE",
      controller: _controller,
      callback: (controller) async {
        await controller.setFlashMode(flashMode);
      },
    );
  }
}
