import 'dart:io';

import 'package:equatable/equatable.dart';

class DataVideoCamera extends Equatable {
  final File? videoFile;

  const DataVideoCamera({this.videoFile});

  DataVideoCamera copyWith({
    File? videoFile,
  }) => DataVideoCamera(
    videoFile: videoFile ?? this.videoFile,
  );

  @override
  List<Object?> get props => [
    videoFile,
  ];
}
