import 'dart:ui';

/// Class untuk menyimpan ukuran dokumen
class OverlaySize {
  final double width; // dalam mm
  final double height; // dalam mm
  final String name;
  final String description;
  final String standard;

  const OverlaySize({
    required this.width,
    required this.height,
    required this.name,
    required this.description,
    required this.standard,
  });

  // Passport Photo
  OverlaySize.passportPhoto()
    : width = 35.0,
      height = 45.0,
      name = 'Passport Photo',
      description = 'Foto paspor standar',
      standard = 'ISO/IEC 19794-5';

  // Pas Foto 2x3 cm
  OverlaySize.pasFoto2x3()
    : width = 20.0,
      height = 30.0,
      name = 'Pas Foto 2x3 cm',
      description = 'Pas foto ukuran 2x3 cm (SKHUN, SKCK)',
      standard = 'Standar Indonesia';

  // Pas Foto 3x4 cm
  OverlaySize.pasFoto3x4()
    : width = 30.0,
      height = 40.0,
      name = 'Pas Foto 3x4 cm',
      description = 'Pas foto ukuran 3x4 cm (KTP, SIM, Ijazah)',
      standard = 'Standar Indonesia';

  // Pas Foto 4x6 cm
  OverlaySize.pasFoto4x6()
    : width = 40.0,
      height = 60.0,
      name = 'Pas Foto 4x6 cm',
      description = 'Pas foto ukuran 4x6 cm (Passport, Visa)',
      standard = 'Standar Indonesia';

  // Foto 2R (6x9 cm)
  OverlaySize.pasFoto2R()
    : width = 60.0,
      height = 90.0,
      name = 'Foto 2R',
      description = 'Foto cetak 2R (6x9 cm)',
      standard = 'ISO Standard';

  // Foto 3R (9x13 cm / 3.5x5 inch)
  OverlaySize.pasFoto3R()
    : width = 89.0,
      height = 127.0,
      name = 'Foto 3R',
      description = 'Foto cetak 3R (9x13 cm / 3.5x5 inch)',
      standard = 'ISO Standard';

  // Foto 4R (10x15 cm / 4x6 inch)
  OverlaySize.pasFoto4R()
    : width = 102.0,
      height = 152.0,
      name = 'Foto 4R',
      description = 'Foto cetak 4R (10x15 cm / 4x6 inch)',
      standard = 'ISO Standard';

  // Foto 5R (13x18 cm / 5x7 inch)
  OverlaySize.pasFoto5R()
    : width = 127.0,
      height = 178.0,
      name = 'Foto 5R',
      description = 'Foto cetak 5R (13x18 cm / 5x7 inch)',
      standard = 'ISO Standard';

  // Foto 8R (20x25 cm / 8x10 inch)
  OverlaySize.pasFoto8R()
    : width = 203.0,
      height = 254.0,
      name = 'Foto 8R',
      description = 'Foto cetak 8R (20x25 cm / 8x10 inch)',
      standard = 'ISO Standard';

  // Foto 10R (25x30 cm / 10x12 inch)
  OverlaySize.pasFoto10R()
    : width = 254.0,
      height = 305.0,
      name = 'Foto 10R',
      description = 'Foto cetak 10R (25x30 cm / 10x12 inch)',
      standard = 'ISO Standard';

  // A4 Paper
  OverlaySize.paperA4()
    : width = 210.0,
      height = 297.0,
      name = 'A4 Paper',
      description = 'Kertas A4 standar',
      standard = 'ISO 216';

  // A5 Paper
  OverlaySize.paperA5()
    : width = 148.0,
      height = 210.0,
      name = 'A5 Paper',
      description = 'Kertas A5 setengah A4',
      standard = 'ISO 216';

  // A6 Paper
  OverlaySize.paperA6()
    : width = 105.0,
      height = 148.0,
      name = 'A6 Paper',
      description = 'Kertas A6 seperempat A4',
      standard = 'ISO 216';

  // ID Card Standard ISO
  OverlaySize.idCard()
    : width = 85.6,
      height = 53.98,
      name = 'ID Card ISO Standard',
      description = 'Kartu identitas standar internasional',
      standard = 'ISO/IEC 7810 ID-1';

  // SIM Card (Mini-SIM)
  OverlaySize.simCard()
    : width = 25.0,
      height = 15.0,
      name = 'SIM Card',
      description = 'Mini-SIM Card',
      standard = 'ISO/IEC 7810 ID-000';

  // Passport
  OverlaySize.passport()
    : width = 125.0,
      height = 88.0,
      name = 'Passport',
      description = 'Paspor standar internasional',
      standard = 'ICAO Doc 9303';

  // Credit Card
  const OverlaySize.creditCard()
    : width = 85.6,
      height = 53.98,
      name = 'Credit Card',
      description = 'Kartu kredit/debit standar',
      standard = 'ISO/IEC 7810 ID-1';

  // Business Card
  const OverlaySize.businessCard()
    : width = 90.0,
      height = 55.0,
      name = 'Business Card',
      description = 'Kartu nama standar Asia',
      standard = 'ISO 216 (variant)';

  // Family Card (Kartu Keluarga)
  const OverlaySize.familyCard()
    : width = 210.0,
      height = 330.0,
      name = 'Kartu Keluarga',
      description = 'Kartu Keluarga Indonesia',
      standard = 'Custom Indonesia';

  Size toOverlaySize(Size screenSize, {double scaleFactor = 0.8}) {
    final aspectRatio = width / height;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Hitung ukuran berdasarkan orientasi dokumen
    double overlayWidth;
    double overlayHeight;

    if (aspectRatio >= 1.0) {
      // Dokumen landscape atau square - scale berdasarkan width
      overlayWidth = screenWidth * scaleFactor;
      overlayHeight = overlayWidth / aspectRatio;

      // Pastikan height tidak melebihi screen height
      if (overlayHeight > screenHeight * scaleFactor) {
        overlayHeight = screenHeight * scaleFactor;
        overlayWidth = overlayHeight * aspectRatio;
      }
    } else {
      // Dokumen portrait - scale berdasarkan height
      overlayHeight = screenHeight * scaleFactor;
      overlayWidth = overlayHeight * aspectRatio;

      // Pastikan width tidak melebihi screen width
      if (overlayWidth > screenWidth * scaleFactor) {
        overlayWidth = screenWidth * scaleFactor;
        overlayHeight = overlayWidth / aspectRatio;
      }
    }

    return Size(overlayWidth, overlayHeight);
  }

  /// Alternative method dengan maxWidth dan maxHeight terpisah
  Size toOverlaySizeFromDimensions(
    double maxWidth,
    double maxHeight, {
    double scaleFactor = 0.8,
  }) {
    return toOverlaySize(Size(maxWidth, maxHeight), scaleFactor: scaleFactor);
  }

  /// Mendapatkan aspect ratio
  double get aspectRatio => width / height;
}
