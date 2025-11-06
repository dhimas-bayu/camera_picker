import 'package:equatable/equatable.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeDetectionResult extends Equatable {
  final List<Barcode>? result;
  final InputImageMetadata? metadata;
  final DateTime? timestamp;

  const BarcodeDetectionResult({this.result, this.metadata, this.timestamp});

  BarcodeDetectionResult copyWith({
    List<Barcode>? result,
    InputImageMetadata? metadata,
    DateTime? timestamp,
  }) => BarcodeDetectionResult(
    result: result ?? this.result,
    metadata: metadata ?? this.metadata,
    timestamp: timestamp ?? this.timestamp,
  );

  @override
  List<Object?> get props => [result, metadata, timestamp];
}
