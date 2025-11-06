import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class DataTakeCamera extends Equatable {
  final File? imageFile;
  final CameraLensDirection? lensDirection;

  const DataTakeCamera({this.imageFile, this.lensDirection});

  DataTakeCamera copyWith({
    final File? imageFile,
    CameraLensDirection? lensDirection,
  }) => DataTakeCamera(
    imageFile: imageFile ?? this.imageFile,
    lensDirection: lensDirection ?? this.lensDirection,
  );

  @override
  List<Object?> get props => [
    imageFile,
    lensDirection,
  ];
}
