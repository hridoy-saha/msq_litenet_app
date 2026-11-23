import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/mango_prediction.dart';

class TfliteClassifierService {
  Interpreter? _interpreter;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    final options = InterpreterOptions()..threads = 4;
    _interpreter = await Interpreter.fromAsset(
      AppConstants.modelAssetPath,
      options: options,
    );
    _interpreter!.allocateTensors();
    _isInitialized = true;
  }

  Future<MangoPrediction> classifyImage(String imagePath) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();
    final bytes = await File(imagePath).readAsBytes();

    final inputTensor = await Isolate.run(() => _preprocessImageBytes(bytes));

    final outputBuffer = List.generate(
      1,
      (_) => List<double>.filled(AppConstants.numClasses, 0.0),
    );

    _interpreter!.run(inputTensor, outputBuffer);
    stopwatch.stop();

    final scores = outputBuffer[0];
    final Map<String, double> probabilities = {};
    int bestIndex = 0;
    double bestScore = -1.0;

    for (int i = 0; i < AppConstants.classNames.length; i++) {
      final score = scores[i].clamp(0.0, 1.0);
      probabilities[AppConstants.classNames[i]] = score;
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    return MangoPrediction(
      imagePath: imagePath,
      label: AppConstants.classNames[bestIndex],
      confidence: bestScore,
      probabilities: probabilities,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
      timestamp: DateTime.now(),
    );
  }

  static List<List<List<List<double>>>> _preprocessImageBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Invalid image format');
    }

    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(
      oriented,
      width: AppConstants.inputSize,
      height: AppConstants.inputSize,
      interpolation: img.Interpolation.linear,
    );

    return List.generate(
      1,
      (_) => List.generate(
        AppConstants.inputSize,
        (y) => List.generate(
          AppConstants.inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
