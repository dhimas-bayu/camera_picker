import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

class DataVideoCamera extends Equatable {
  final File? videoFile;
  final CameraLensDirection? lensDirection;

  const DataVideoCamera({this.videoFile, this.lensDirection});

  DataVideoCamera copyWith({
    final File? videoFile,
    CameraLensDirection? lensDirection,
  }) => DataVideoCamera(
    videoFile: videoFile ?? this.videoFile,
    lensDirection: lensDirection ?? this.lensDirection,
  );

  @override
  List<Object?> get props => [
    videoFile,
    lensDirection,
  ];
}
