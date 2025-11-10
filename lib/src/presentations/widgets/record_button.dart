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
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.recordDuration,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_controller);

    _controller.addListener(_animateListener);
    widget.controller?.addListener(_cameraListener);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_cameraListener);
    _recordNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _cameraListener() {
    final isRecording = widget.controller?.value.isRecordingVideo;
    _recordNotifier.value = isRecording ?? false;
  }

  void _animateListener() {
    if (_animation.isCompleted) {
      _controller.reset();
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
            width: 72.0,
            height: 72.0,
            decoration: const ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.white24,
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
                  duration: Durations.short2,
                  width: isRecording ? 28.0 : 48.0,
                  height: isRecording ? 28.0 : 48.0,
                  margin: isRecording
                      ? const EdgeInsets.all(16.0)
                      : const EdgeInsets.all(8.0),
                  decoration: ShapeDecoration(
                    color: isRecording ? Colors.red : Colors.white,
                    shape: isRecording
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(12.0),
                          )
                        : const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            if (isRecording) {
              _controller.reset();
              widget.onStopRecording?.call();
            } else {
              _controller.forward();
              widget.onStartRecording?.call();
            }
          },
        );
      },
    );
  }
}
