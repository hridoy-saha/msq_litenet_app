class AppConstants {
  AppConstants._();

  static const String appName = 'MSQ-LiteNet';
  static const String appSubtitle = 'Mango Quality & Shelf-Life AI';
  static const String modelAssetPath = 'assets/models/msq_litenet_fp16.tflite';

  static const int inputSize = 256;
  static const int numClasses = 5;

  static const List<String> classNames = [
    'Fully Ripe',
    'Over Ripe',
    'Rotten',
    'Semi Ripe',
    'Unripe',
  ];

  static const double pagePadding = 20.0;
  static const double sectionGap = 20.0;
  static const double itemGap = 12.0;
  static const double cardPadding = 18.0;

  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 22.0;
  static const double radiusXl = 28.0;

  static const double buttonHeight = 52.0;
  static const double dialogMaxWidth = 420.0;
  static const double sheetMaxWidth = 480.0;
  static const double previewHeight = 256.0;
}
