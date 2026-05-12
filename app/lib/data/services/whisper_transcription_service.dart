import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class WhisperTranscriptionService {
  // base model: good balance of speed and accuracy (~145MB, downloaded once)
  static const _model = WhisperModel.base;

  Whisper? _whisper;

  Future<String> transcribe(String audioFilePath) async {
    debugPrint('[Whisper] transcribe() called — audio: $audioFilePath');

    final audioFile = File(audioFilePath);
    if (!audioFile.existsSync()) {
      debugPrint('[Whisper] ERROR: audio file does not exist at $audioFilePath');
      throw Exception('Audio file not found: $audioFilePath');
    }
    debugPrint('[Whisper] audio file size: ${audioFile.lengthSync()} bytes');

    _whisper ??= const Whisper(model: _model);
    debugPrint('[Whisper] model: ${_model.modelName} — checking/downloading…');

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioFilePath,
          isNoTimestamps: true,
          splitOnWord: true,
        ),
      );
      stopwatch.stop();
      debugPrint('[Whisper] done in ${stopwatch.elapsedMilliseconds}ms — text: "${response.text.trim()}"');
      return response.text.trim();
    } catch (e, st) {
      stopwatch.stop();
      debugPrint('[Whisper] ERROR after ${stopwatch.elapsedMilliseconds}ms: $e');
      debugPrint('[Whisper] stack: $st');
      rethrow;
    }
  }

  void dispose() {
    _whisper = null;
  }
}
