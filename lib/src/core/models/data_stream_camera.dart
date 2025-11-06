import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

class DataStreamCamera extends Equatable {
  final CameraImage? image;
  final CameraLensDirection? lensDirection;
  final DeviceOrientation? deviceOrientation;
  final int? sensorOrientation;

  const DataStreamCamera({
    this.image,
    this.lensDirection,
    this.deviceOrientation,
    this.sensorOrientation,
  });

  DataStreamCamera copyWith({
    CameraImage? image,
    CameraLensDirection? lensDirection,
    DeviceOrientation? deviceOrientation,
    int? sensorOrientation,
  }) => DataStreamCamera(
    image: image ?? this.image,
    lensDirection: lensDirection ?? this.lensDirection,
    deviceOrientation: deviceOrientation ?? this.deviceOrientation,
    sensorOrientation: sensorOrientation ?? this.sensorOrientation,
  );

  @override
  List<Object?> get props => [
    image,
    lensDirection,
    deviceOrientation,
    sensorOrientation,
  ];
}
