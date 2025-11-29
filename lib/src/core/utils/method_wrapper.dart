import 'package:camera/camera.dart';

Future<T?> methodWrapper<T>(
  String tag, {
  CameraController? controller,
  Function(CameraController controller)? callback,
  T? fallback,
}) async {
  if (controller == null || !controller.value.isInitialized) {
    return fallback;
  }

  try {
    return await callback?.call(controller);
  } catch (e) {
    rethrow;
  }
}
