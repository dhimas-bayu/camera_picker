import 'package:camera/camera.dart';
import 'package:camera_picker/src/presentations/painters/record_progress_painter.dart';
import 'package:flutter/material.dart';

class RecordButton extends StatefulWidget {
  const RecordButton({
    super.key,
    required this.recordDuration,
    this.controller,
    this.onStartRecording,
    this.onStopRecording,
  });
  final Duration recordDuration;
  final CameraController? controller;
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _recordNotifier = ValueNotifier(false);
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.recordDuration,
    );

    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController);
    _animationController.addListener(_animateListener);
    widget.controller?.addListener(_cameraListener);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_cameraListener);
    _recordNotifier.dispose();
    _animationController.removeListener(_animateListener);
    _animationController.dispose();
    super.dispose();
  }

  void _cameraListener() {
    _recordNotifier.value = widget.controller?.value.isRecordingVideo ?? false;
    debugPrint("IS RECORDING : ${_recordNotifier.value}");
  }

  void _animateListener() {
    if (_animation.isCompleted) {
      _animationController.reset();
      widget.onStopRecording?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: _recordNotifier,
      builder: (context, isRecording, child) {
        return GestureDetector(
          child: Container(
            width: 64.0,
            height: 64.0,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white38,
            ),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => CustomPaint(
                    painter: RecordProgressPainter(
                      animationValue: _animation.value,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Durations.short4,
                  width: 48.0,
                  height: 48.0,
                  margin: isRecording
                      ? const EdgeInsets.all(12.0)
                      : const EdgeInsets.all(8.0),
                  decoration: ShapeDecoration(
                    color: isRecording ? Colors.red : Colors.white,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            if (isRecording) {
              _animationController.reset();
              widget.onStopRecording?.call();
            } else {
              _animationController.forward();
              widget.onStartRecording?.call();
            }
          },
        );
      },
    );
  }
}
