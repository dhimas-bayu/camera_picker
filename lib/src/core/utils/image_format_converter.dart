import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image/image.dart' as img;

class ImageFormatConverter {
  static Future<InputImage?> convertToInputImage(
    CameraImage image, {
    DeviceOrientation? deviceOrientation,
    CameraLensDirection? lensDirection,
    int? sensorOrientation,
  }) async {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToInputImage(
          image,
          deviceOrientation: deviceOrientation,
          lensDirection: lensDirection,
          sensorOrientation: sensorOrientation,
        );
      } else if (image.format.group == ImageFormatGroup.nv21) {
        return _convertNV21ToInputImage(
          image,
          deviceOrientation: deviceOrientation,
          lensDirection: lensDirection,
          sensorOrientation: sensorOrientation,
        );
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToInputImage(
          image,
          deviceOrientation: deviceOrientation,
          lensDirection: lensDirection,
          sensorOrientation: sensorOrientation,
        );
      } else {
        developer.log('Unsupported image format: ${image.format.group}');
        return null;
      }
    } catch (e) {
      developer.log('Image conversion error: $e');
      return null;
    }
  }

  static Future<InputImage> _convertNV21ToInputImage(
    CameraImage image, {
    DeviceOrientation? deviceOrientation,
    CameraLensDirection? lensDirection,
    int? sensorOrientation,
  }) async {
    final planes = image.planes[0];
    final bytes = planes.bytes;
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final imageRotation = _getRotation(
      lensDirection: lensDirection,
      sensorOrientation: sensorOrientation,
      deviceOrientation: deviceOrientation,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width, height),
        rotation: imageRotation ?? InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: planes.bytesPerRow,
      ),
    );
  }

  static Future<InputImage> _convertYUV420ToInputImage(
    CameraImage image, {
    DeviceOrientation? deviceOrientation,
    CameraLensDirection? lensDirection,
    int? sensorOrientation,
  }) async {
    final bytes = await _convertYUV420ToNV21(image);
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final imageRotation = _getRotation(
      lensDirection: lensDirection,
      sensorOrientation: sensorOrientation,
      deviceOrientation: deviceOrientation,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width, height),
        rotation: imageRotation ?? InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static Future<InputImage> _convertBGRA8888ToInputImage(
    CameraImage image, {
    DeviceOrientation? deviceOrientation,
    CameraLensDirection? lensDirection,
    int? sensorOrientation,
  }) async {
    final bytes = image.planes[0].bytes;
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final imageRotation = _getRotation(
      lensDirection: lensDirection,
      sensorOrientation: sensorOrientation,
      deviceOrientation: deviceOrientation,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width, height),
        rotation: imageRotation ?? InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  static Future<Uint8List> convertImageToBytes(
    CameraImage image, {
    bool useIsolate = true,
  }) async {
    if (!useIsolate) return _convertImageToBytes(image);
    return Isolate.run(() async {
      return await _convertImageToBytes(image);
    });
  }

  static Future<ui.Image> convertBytesToUiImage(
    Uint8List image,
    int width,
    int height, {
    bool useIsolate = true,
  }) async {
    if (!useIsolate) {
      return _convertRGB888ToUiImage(
        image,
        width,
        height,
      );
    }

    return Isolate.run(
      () async => await _convertRGB888ToUiImage(
        image,
        width,
        height,
      ),
    );
  }

  static Future<Uint8List> _convertImageToBytes(CameraImage image) async {
    switch (image.format.group) {
      case ImageFormatGroup.yuv420:
        return _convertYUV420ToRGB888(image);
      case ImageFormatGroup.nv21:
        return _convertNV21ToRGB888(image);
      case ImageFormatGroup.bgra8888:
        return _convertBGRA8888ToRGB888(image);
      case ImageFormatGroup.jpeg:
        return _convertJPEGToRGB888(image);
      default:
        throw Exception('Unsupported image format: ${image.format}');
    }
  }

  static Future<Uint8List> cropImageBytes(
    CameraImage image,
    ui.Rect cropRect, {
    bool useIsolate = true,
  }) async {
    if (!useIsolate) {
      return _cropImageBytes(
        image,
        cropRect.left.round(),
        cropRect.top.round(),
        cropRect.width.round(),
        cropRect.height.round(),
      );
    }
    return Isolate.run(
      () async {
        return await _cropImageBytes(
          image,
          cropRect.left.round(),
          cropRect.top.round(),
          cropRect.width.round(),
          cropRect.height.round(),
        );
      },
    );
  }

  /// YUV420 → RGB888
  static Future<Uint8List> _convertYUV420ToRGB888(CameraImage image) async {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width = image.width;
    final height = image.height;

    final out = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final uvRow = y ~/ 2;
        final uvCol = x ~/ 2;

        final Y = yPlane.bytes[y * yPlane.bytesPerRow + x];
        final U = uPlane.bytes[uvRow * uPlane.bytesPerRow + uvCol];
        final V = vPlane.bytes[uvRow * vPlane.bytesPerRow + uvCol];

        final r = (Y + 1.402 * (V - 128)).clamp(0, 255).toInt();
        final g = (Y - 0.344136 * (U - 128) - 0.714136 * (V - 128))
            .clamp(0, 255)
            .toInt();
        final b = (Y + 1.772 * (U - 128)).clamp(0, 255).toInt();

        final index = (y * width + x) * 3;
        out[index] = r;
        out[index + 1] = g;
        out[index + 2] = b;
      }
    }
    return out;
  }

  /// NV21 → RGB888
  static Future<Uint8List> _convertNV21ToRGB888(CameraImage image) async {
    final yPlane = image.planes[0];
    final uvPlane = image.planes[1];

    final width = image.width;
    final height = image.height;

    final out = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final uvRow = y ~/ 2;
        final uvCol = (x ~/ 2) * 2;

        final Y = yPlane.bytes[y * yPlane.bytesPerRow + x];
        final V = uvPlane.bytes[uvRow * uvPlane.bytesPerRow + uvCol];
        final U = uvPlane.bytes[uvRow * uvPlane.bytesPerRow + uvCol + 1];

        final r = (Y + 1.402 * (V - 128)).clamp(0, 255).toInt();
        final g = (Y - 0.344136 * (U - 128) - 0.714136 * (V - 128))
            .clamp(0, 255)
            .toInt();
        final b = (Y + 1.772 * (U - 128)).clamp(0, 255).toInt();

        final index = (y * width + x) * 3;
        out[index] = r;
        out[index + 1] = g;
        out[index + 2] = b;
      }
    }
    return out;
  }

  /// YUV420 → NV21
  static Future<Uint8List> _convertYUV420ToNV21(CameraImage image) async {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final width = image.width;
    final height = image.height;

    final ySize = width * height;
    final uvSize = width * height ~/ 2;

    final out = Uint8List(ySize + uvSize);

    // Copy Y
    int offset = 0;
    for (int row = 0; row < height; row++) {
      out.setRange(
        offset,
        offset + width,
        yPlane.bytes.sublist(
          row * yPlane.bytesPerRow,
          row * yPlane.bytesPerRow + width,
        ),
      );
      offset += width;
    }

    // Copy VU interleaved
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final u = uPlane.bytes[row * uPlane.bytesPerRow + col];
        final v = vPlane.bytes[row * vPlane.bytesPerRow + col];
        out[offset++] = v;
        out[offset++] = u;
      }
    }

    return out;
  }

  /// BGRA8888 → RGB888
  static Future<Uint8List> _convertBGRA8888ToRGB888(CameraImage image) async {
    final plane = image.planes.first;
    final bytes = plane.bytes;

    final width = image.width;
    final height = image.height;

    final out = Uint8List(width * height * 3);

    for (int i = 0; i < width * height; i++) {
      final b = bytes[i * 4];
      final g = bytes[i * 4 + 1];
      final r = bytes[i * 4 + 2];

      final idx = i * 3;
      out[idx] = r;
      out[idx + 1] = g;
      out[idx + 2] = b;
    }
    return out;
  }

  /// JPEG → RGB888
  static Future<Uint8List> _convertJPEGToRGB888(CameraImage image) async {
    final plane = image.planes.first;
    final decoded = img.decodeJpg(plane.bytes);
    if (decoded == null) throw Exception('Failed to decode JPEG');
    final rgb = decoded.convert(numChannels: 3);
    return rgb.toUint8List();
  }

  /// RGB888 → ui.Image
  static Future<ui.Image> _convertRGB888ToUiImage(
    Uint8List rgbBytes,
    int width,
    int height,
  ) async {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgbBytes,
      width,
      height,
      ui.PixelFormat.rgba8888,
      c.complete,
    );
    return c.future;
  }

  /// Crop image bytes (YUV420, NV21, or BGRA8888)
  static Future<Uint8List> _cropImageBytes(
    CameraImage image,
    int startX,
    int startY,
    int cropWidth,
    int cropHeight,
  ) async {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _cropYUV420toNV21(image, startX, startY, cropWidth, cropHeight);
    } else if (image.format.group == ImageFormatGroup.nv21) {
      return _cropImageToNV21(image, startX, startY, cropWidth, cropHeight);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _cropImageToBGRA(image, startX, startY, cropWidth, cropHeight);
    } else {
      throw ArgumentError('Unsupported format for cropping');
    }
  }

  /// Crop image bytes to YUV420
  static Future<Uint8List> _cropImageToYUV420(
    CameraImage image,
    int left,
    int top,
    int width,
    int height,
  ) async {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final cropped = Uint8List(width * height * 3 ~/ 2);

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    int index = 0;

    // 🔹 Copy Y
    for (int row = 0; row < height; row++) {
      final srcRow = (row + top) * yPlane.bytesPerRow;
      final dstRow = row * width;
      cropped.setRange(
        dstRow,
        dstRow + width,
        yBuffer.sublist(srcRow + left, srcRow + left + width),
      );
    }
    index = width * height;

    // 🔹 Copy UV (VU interleaved)
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final uIndex =
            (row + top ~/ 2) * uvRowStride + (col + left ~/ 2) * uvPixelStride;
        final vIndex =
            (row + top ~/ 2) * vPlane.bytesPerRow +
            (col + left ~/ 2) * (vPlane.bytesPerPixel ?? 1);

        // pastikan tidak out of range
        if (uIndex < uBuffer.length && vIndex < vBuffer.length) {
          cropped[index++] = vBuffer[vIndex];
          cropped[index++] = uBuffer[uIndex];
        }
      }
    }

    return cropped;
  }

  /// Crop image bytes to NV21
  static Future<Uint8List> _cropImageToNV21(
    CameraImage image,
    int left,
    int top,
    int width,
    int height,
  ) async {
    final bytes = image.planes[0].bytes;
    final fullWidth = image.width;
    final fullHeight = image.height;

    final ySize = fullWidth * fullHeight;
    final cropped = Uint8List(width * height * 3 ~/ 2);

    int dstIndex = 0;

    // 🔹 Copy Y plane
    for (int row = 0; row < height; row++) {
      final srcRow = (top + row) * fullWidth;
      final dstRow = row * width;
      cropped.setRange(
        dstRow,
        dstRow + width,
        bytes.sublist(srcRow + left, srcRow + left + width),
      );
    }
    dstIndex = width * height;

    // 🔹 Copy UV (VU interleaved)
    for (int row = 0; row < height ~/ 2; row++) {
      final srcRow = (top ~/ 2 + row) * fullWidth;
      for (int col = 0; col < width; col += 2) {
        final srcIndex = ySize + srcRow + left + col;

        if (srcIndex + 1 < bytes.length && dstIndex + 1 < cropped.length) {
          cropped[dstIndex++] = bytes[srcIndex]; // V
          cropped[dstIndex++] = bytes[srcIndex + 1]; // U
        }
      }
    }

    return cropped;
  }

  /// Crop YUV420 and convert to NV21
  static Future<Uint8List> _cropYUV420toNV21(
    CameraImage image,
    int startX,
    int startY,
    int cropWidth,
    int cropHeight,
  ) async {
    if (image.format.group != ImageFormatGroup.yuv420) {
      throw ArgumentError("Format image harus YUV420");
    }

    final left = startX;
    final top = startY;
    final width = cropWidth;
    final height = cropHeight;

    if (left < 0 ||
        top < 0 ||
        left + width > image.width ||
        top + height > image.height) {
      throw ArgumentError("Rect crop melebihi batas ukuran gambar");
    }

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final ySize = width * height;
    final uvSize = width * height ~/ 2;

    final nv21 = Uint8List(ySize + uvSize);

    int dstIndex = 0;

    // 🔹 Copy Y (grayscale luma)
    for (int row = 0; row < height; row++) {
      final srcOffset = (top + row) * yPlane.bytesPerRow + left;
      nv21.setRange(
        dstIndex,
        dstIndex + width,
        yBuffer.sublist(srcOffset, srcOffset + width),
      );
      dstIndex += width;
    }

    // 🔹 Copy UV (VU interleaved untuk NV21)
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final srcU =
            (top ~/ 2 + row) * uvRowStride + (left ~/ 2 + col) * uvPixelStride;
        final srcV =
            (top ~/ 2 + row) * vPlane.bytesPerRow +
            (left ~/ 2 + col) * (vPlane.bytesPerPixel ?? 1);

        if (srcU < uBuffer.length && srcV < vBuffer.length) {
          nv21[dstIndex++] = vBuffer[srcV]; // V
          nv21[dstIndex++] = uBuffer[srcU]; // U
        }
      }
    }

    return nv21;
  }

  /// Crop image bytes to BGRA
  static Future<Uint8List> _cropImageToBGRA(
    CameraImage image,
    int startX,
    int startY,
    int cropWidth,
    int cropHeight,
  ) async {
    final plane = image.planes[0];
    const bytesPerPixel = 4;
    final croppedBytes = Uint8List(cropWidth * cropHeight * 3);
    int rgbIndex = 0;
    for (int y = startY; y < startY + cropHeight; y++) {
      for (int x = startX; x < startX + cropWidth; x++) {
        final pixelIndex = (y * image.width + x) * bytesPerPixel;
        final b = plane.bytes[pixelIndex];
        final g = plane.bytes[pixelIndex + 1];
        final r = plane.bytes[pixelIndex + 2];
        croppedBytes[rgbIndex++] = r;
        croppedBytes[rgbIndex++] = g;
        croppedBytes[rgbIndex++] = b;
      }
    }
    return croppedBytes;
  }

  static InputImageRotation? _getRotation({
    DeviceOrientation? deviceOrientation,
    CameraLensDirection? lensDirection,
    int? sensorOrientation,
  }) {
    // This should be determined based on device orientation
    final orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    InputImageRotation? rotation;
    if (sensorOrientation == null) {
      return rotation;
    }

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = orientations[deviceOrientation];
      if (rotationCompensation != null) {
        if (lensDirection == CameraLensDirection.front) {
          rotationCompensation =
              (sensorOrientation + rotationCompensation) % 360;
        } else {
          rotationCompensation =
              (sensorOrientation - rotationCompensation + 360) % 360;
        }
        rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      }
    }

    return rotation;
  }
}
