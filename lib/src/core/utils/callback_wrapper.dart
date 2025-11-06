import 'dart:developer' as development;

import 'package:camera/camera.dart';

Future<T?> callbackWrapper<T>(
  String key, {
  CameraController? controller,
  Future<T> Function(CameraController)? callback,
  Function(Object)? onError,
  bool showLogDebug = true,
}) async {
  try {
    if (controller == null) {
      if (showLogDebug) {
        development.log("[$key] ERROR : CAMERA CONTROLLER NOT SET");
      }
      return null;
    }

    final CameraController cameraController = controller;
    if (!cameraController.value.isInitialized) {
      if (showLogDebug) {
        development.log("[$key] ERROR :  CAMERA NOT INITIALIZED");
      }
      return null;
    }
    return await callback?.call(controller);
  } catch (e) {
    if (showLogDebug) {
      development.log("[$key] ERROR : $e");
    }
    onError?.call(e);
    rethrow;
  }
}
