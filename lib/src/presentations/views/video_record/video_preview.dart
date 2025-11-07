import 'dart:io';

import 'package:camera_picker/src/presentations/widgets/confirm_button.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({
    super.key,
    required this.videoFile,
    this.onAccepted,
    this.onRejected,
  });
  final File videoFile;
  final VoidCallback? onRejected;
  final VoidCallback? onAccepted;

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> _initNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile);
    _initVideoPlayer();
  }

  @override
  void dispose() {
    _initNotifier.dispose();
    _controller
      ..pause()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: ValueListenableBuilder(
        valueListenable: _initNotifier,
        builder: (context, isInitialized, child) {
          if (isInitialized) {
            return Stack(
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildNavigation(),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
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
            onAction: widget.onRejected,
          ),
          ConfirmButton(
            action: ConfirmAction.accept,
            onAction: widget.onAccepted,
          ),
        ],
      ),
    );
  }

  Future<void> _initVideoPlayer() async {
    try {
      await _controller.initialize();
      _initNotifier.value = _controller.value.isInitialized;

      await Future.wait([
        _controller.play(),
        _controller.setLooping(true),
      ]);
    } catch (e) {
      debugPrint("$e");
    }
  }
}
