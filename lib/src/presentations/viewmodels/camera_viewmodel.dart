import 'camera_size_notifier.dart';
import 'package:flutter/material.dart';

// enum StateAspect { init, previewSize, exposure, imageFile, focus, scale }

class CameraViewModel extends InheritedNotifier<CameraSizeNotifier> {
  const CameraViewModel({
    super.key,
    required CameraSizeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static CameraSizeNotifier? maybeOf(BuildContext context) {
    final model = context.dependOnInheritedWidgetOfExactType<CameraViewModel>();
    return model?.notifier;
  }

  static CameraSizeNotifier of(BuildContext context) {
    final model = context.dependOnInheritedWidgetOfExactType<CameraViewModel>();
    assert(model != null, "CameraViewModel not found in context");
    return model!.notifier!;
  }

  static Size? viewSizeOf(BuildContext context) {
    final state = maybeOf(context);
    return state?.size;
  }
}
