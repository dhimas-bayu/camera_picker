import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import '../../core/models/data_video_camera.dart';
import '../widgets/record_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../camera_picker.dart';
import '../../core/models/data_stream_camera.dart';
import '../../core/models/data_take_camera.dart';
import '../widgets/camera_switcher.dart';
import '../widgets/capture_button.dart';
import '../widgets/flash_mode_switcher.dart';

typedef PreviewBuilder =
    Widget Function(BuildContext context, Size previewSize);

enum CameraStatus {
  init,
  rebuild,
  dispose,
}

class CameraView extends StatefulWidget {
  CameraView({
    super.key,
    required this.cameras,
    required this.resolutionPreset,
    this.mode = CameraMode.takePicture,
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
  });

  final CameraMode mode;
  final List<CameraDescription> cameras;
  final CameraDescription? initCamera;
  final ResolutionPreset resolutionPreset;
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

  CameraStatus _status = CameraStatus.init;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _flashMode = widget.initFlashMode;
    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) {
        _initCameras(description: widget.initCamera);
      });
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.resumed && _status == CameraStatus.rebuild) {
      _initCameras(description: cameraController.description);
    } else if (state == AppLifecycleState.inactive) {
      _status = CameraStatus.rebuild;
      cameraController.dispose();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([]);
    WidgetsBinding.instance.removeObserver(this);
    _status = CameraStatus.dispose;
    _controller?.dispose();
    _currentExposure.dispose();
    _currentScale.dispose();
    _focusOffset.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  onDoubleTapDown: (details) async {
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

  Future<T?> _methodWrapper<T>(
    String tag, {
    Future<T?> Function()? method,
    T? fallback,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return fallback;
    }

    try {
      if (!mounted) {
        return fallback;
      }

      return await method?.call();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initCameras({
    CameraDescription? description,
  }) async {
    _cameras = widget.cameras;
    if (_cameras.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorMessage("Camera not detected");
        return;
      });
    }

    if (_status == CameraStatus.dispose) {
      debugPrint("controller is disposed");
      return;
    }

    _status = CameraStatus.init;
    _description = description ?? _initCameraDescription();
    if (_validFlashMode.isEmpty) _availableFlashModes();

    ImageFormatGroup? imageFormatGroup = switch (widget.mode) {
      CameraMode.takePicture => ImageFormatGroup.jpeg,
      _ => Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21,
    };

    final cameraController = CameraController(
      _description!,
      widget.resolutionPreset,
      imageFormatGroup: imageFormatGroup,
      enableAudio: false,
    );

    _controller = cameraController;
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (cameraController.value.hasError) {
        debugPrint(
          'camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      await cameraController.initialize();
      if (mounted && cameraController.value.isInitialized) {
        widget.onSwitchCamera?.call(_description);
      }

      await Future.wait([
        _methodWrapper<double>(
          "getMaxExposureOffset",
          method: () => cameraController.getMaxExposureOffset(),
          fallback: _maxAvailableExposureOffset,
        ).then((value) {
          _maxAvailableExposureOffset = value!;
        }),
        _methodWrapper<double>(
          "getMinExposureOffset",
          method: () => cameraController.getMinExposureOffset(),
          fallback: _minAvailableExposureOffset,
        ).then((value) {
          _minAvailableExposureOffset = value!;
        }),
        _methodWrapper<double>(
          "getMinZoomLevel",
          method: () => cameraController.getMinZoomLevel(),
          fallback: _minAvailableZoom,
        ).then((value) {
          _minAvailableZoom = value!;
        }),
        _methodWrapper<double>(
          "getMaxZoomLevel",
          method: () => cameraController.getMaxZoomLevel(),
          fallback: _maxAvailableZoom,
        ).then((value) {
          _maxAvailableZoom = value!;
        }),
      ], eagerError: true);

      if (widget.mode == CameraMode.videoRecord) {
        _methodWrapper<void>(
          "prepareVideoRecording",
          method: () => cameraController.prepareForVideoRecording(),
        );
      }

      if (widget.mode == CameraMode.scanBarcode) {
        _minProcessInterval = Duration(
          milliseconds: (1000 / widget.targetStreamFPS).round(),
        );

        _methodWrapper<void>(
          "prepareVideoRecording",
          method: () => cameraController.prepareForVideoRecording(),
        );

        cameraController.startImageStream(_streamImage);
      }
    } on CameraException catch (e) {
      debugPrint("CameraException: $e");
      rethrow;
    } on Exception catch (e) {
      debugPrint("Exception: $e");
      rethrow;
    }
  }

  CameraDescription _initCameraDescription() {
    final backCamera = _cameras.firstWhereOrNull((e) {
      return e.lensDirection == CameraLensDirection.back;
    });
    return backCamera ?? _cameras[0];
  }

  void _availableFlashModes() {
    for (final mode in CameraMode.values) {
      List<FlashMode> flashMode = switch (mode) {
        CameraMode.takePicture => FlashMode.values,
        _ => [FlashMode.off, FlashMode.torch],
      };

      _validFlashMode.addAll({mode: flashMode});
    }
  }

  Future<void> _streamImage(
    CameraImage image,
  ) async {
    if (!_shouldSkipProcessing()) {
      _dataStreamCamera = _dataStreamCamera.copyWith(
        image: image,
        deviceOrientation: _controller?.value.deviceOrientation,
        lensDirection: _controller?.description.lensDirection,
        sensorOrientation: _controller?.description.sensorOrientation,
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
    String tag = "takePicture";
    await _methodWrapper<void>(
      tag,
      method: () async {
        if (_controller!.value.isTakingPicture) return;
        final imageFile = await _controller!.takePicture();
        _dataTakeCamera = _dataTakeCamera.copyWith(
          imageFile: File(imageFile.path),
        );

        widget.onTakePicture?.call(_dataTakeCamera);
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  Future<void> _handleStartRecording() async {
    await _methodWrapper<void>(
      "startRecordingVideo",
      method: () async {
        if (_controller!.value.isRecordingVideo) return;
        await _controller!.startVideoRecording();
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  Future<void> _handleStopRecording() async {
    await _methodWrapper<void>(
      "stopRecordingVideo",
      method: () async {
        if (!_controller!.value.isRecordingVideo) return;
        final videoFile = await _controller!.stopVideoRecording();
        _dataVideoCamera = _dataVideoCamera.copyWith(
          videoFile: File(videoFile.path),
        );

        widget.onRecordVideo?.call(_dataVideoCamera);
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  Future<void> _handleZoom(double scale) async {
    if (_maxAvailableZoom == _minAvailableZoom) return;
    final zoom = (_baseScale * scale).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );

    if (zoom == _currentScale.value) return;

    await _methodWrapper<void>(
      "setZoomLevel",
      method: () async {
        await _controller!.setZoomLevel(zoom);
        _currentScale.value = zoom;
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale.value;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_pointers != 2) return;
    _handleZoom(details.scale);
  }

  Future<void> _handleFocus(Offset offset) async {
    await _methodWrapper<void>(
      "setFocusPoint",
      method: () async {
        _focusOffset.value = offset;

        await Future.wait([
          _controller!.setFocusMode(FocusMode.locked),
          _controller!.setFocusPoint(offset),
          _controller!.setExposurePoint(offset),
        ], eagerError: true);

        Future.delayed(
          const Duration(seconds: 1),
          () => _focusOffset.value = null,
        );
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
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
    await _methodWrapper(
      "switchCamera",
      method: () async {
        final description = _cameras.firstWhereOrNull(
          (d) => d.lensDirection == direction,
        );

        await _initCameras(description: description);
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  Future<void> _handleSwitchFlashMode(FlashMode? flashMode) async {
    if (flashMode == null) return;
    await _methodWrapper(
      "switchFlashMode",
      method: () async {
        await _controller!.setFlashMode(flashMode);
        _flashMode = flashMode;
        widget.onSwitchFlash?.call(_flashMode);
      },
    ).onError((e, stackTrace) {
      _showErrorMessage(e.toString());
    });
  }

  Future<void> _showErrorMessage(String message) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text("Camera Picker"),
          titleTextStyle: const TextStyle(fontSize: 16.0, color: Colors.black),
          content: Text(message),
          contentTextStyle: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
