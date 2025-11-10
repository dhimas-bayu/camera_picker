import 'dart:io';

import 'package:equatable/equatable.dart';

class DataTakeCamera extends Equatable {
  final File? imageFile;

  const DataTakeCamera({this.imageFile});

  DataTakeCamera copyWith({
    final File? imageFile,
  }) => DataTakeCamera(
    imageFile: imageFile ?? this.imageFile,
  );

  @override
  List<Object?> get props => [
    imageFile,
  ];
}
