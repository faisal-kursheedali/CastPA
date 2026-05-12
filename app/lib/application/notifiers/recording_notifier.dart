import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:castpa/data/services/whisper_transcription_service.dart';

enum RecordingStatus { idle, recording, transcribing, error }

class RecordingState {
  final RecordingStatus status;
  final String? error;
  final String? transcript;

  const RecordingState({
    this.status = RecordingStatus.idle,
    this.error,
    this.transcript,
  });

  bool get isIdle => status == RecordingStatus.idle;
  bool get isRecording => status == RecordingStatus.recording;
  bool get isTranscribing => status == RecordingStatus.transcribing;

  RecordingState copyWith({
    RecordingStatus? status,
    String? error,
    String? transcript,
    bool clearError = false,
    bool clearTranscript = false,
  }) {
    return RecordingState(
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      transcript: clearTranscript ? null : transcript ?? this.transcript,
    );
  }
}

class RecordingNotifier extends AutoDisposeNotifier<RecordingState> {
  late final AudioRecorder _recorder;
  late final WhisperTranscriptionService _whisper;
  String? _audioPath;

  @override
  RecordingState build() {
    _recorder = AudioRecorder();
    _whisper = WhisperTranscriptionService();
    ref.onDispose(() {
      _recorder.dispose();
      _whisper.dispose();
    });
    return const RecordingState();
  }

  Future<void> startRecording() async {
    try {
      // permission_handler has no macOS implementation; the record package
      // handles microphone permission natively on macOS via its own API.
      if (!Platform.isMacOS) {
        final micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) {
          state = state.copyWith(
            status: RecordingStatus.error,
            error: 'Microphone permission denied.',
          );
          return;
        }
      } else {
        final granted = await _recorder.hasPermission();
        if (!granted) {
          state = state.copyWith(
            status: RecordingStatus.error,
            error: 'Microphone permission denied.',
          );
          return;
        }
      }

      final tmpDir = await getTemporaryDirectory();
      // Ensure the directory exists — AVCaptureAudioFileOutput won't create it.
      await Directory(tmpDir.path).create(recursive: true);
      _audioPath = p.join(
        tmpDir.path,
        'castpa_recording_${DateTime.now().millisecondsSinceEpoch}.wav',
      );

      debugPrint('[Recording] starting recorder → $_audioPath');
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _audioPath!,
      );
      debugPrint('[Recording] recorder started');

      state = state.copyWith(
        status: RecordingStatus.recording,
        clearError: true,
        clearTranscript: true,
      );
      debugPrint('[Recording] state set to recording');
    } catch (e) {
      debugPrint('[Recording] startRecording error: $e');
      state = state.copyWith(
        status: RecordingStatus.error,
        error: 'Could not start recording: $e',
      );
    }
  }

  Future<void> stopAndTranscribe() async {
    debugPrint('[Recording] stopAndTranscribe() called — status: ${state.status}');
    if (!state.isRecording) {
      debugPrint('[Recording] stopAndTranscribe() — NOT recording, returning early');
      return;
    }
    // Immediately mark as transcribing so the UI leaves the recording state
    // even if the stop call or transcription take a moment.
    state = state.copyWith(status: RecordingStatus.transcribing);
    String? path;
    try {
      debugPrint('[Recording] stopping recorder…');
      // record_macos bug: stopCb is assigned after stopRecording() fires its
      // delegate, so the Dart Future never completes on macOS. Work around it
      // with a 4-second timeout and fall back to the known audio path.
      path = await _recorder.stop().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[Recording] stop() timed out — using cached path: $_audioPath');
          return _audioPath;
        },
      );
      debugPrint('[Recording] recorder stopped — path: $path');

      // AVFoundation writes the file asynchronously after stop. If the file
      // isn't there yet, poll for up to 10 seconds before giving up.
      final pendingPath = path;
      if (pendingPath != null && !File(pendingPath).existsSync()) {
        debugPrint('[Recording] file not yet on disk — polling…');
        bool found = false;
        for (int i = 0; i < 50; i++) {
          await Future.delayed(const Duration(milliseconds: 200));
          final f = File(pendingPath);
          if (f.existsSync() && f.lengthSync() > 0) {
            debugPrint('[Recording] file ready after ${(i + 1) * 200}ms (${f.lengthSync()} bytes)');
            found = true;
            break;
          }
        }
        if (!found) {
          debugPrint('[Recording] file never appeared after 10s');
          path = null;
        }
      }
    } catch (e) {
      debugPrint('[Recording] stop error: $e');
      state = state.copyWith(
        status: RecordingStatus.error,
        error: 'Could not stop recording: $e',
      );
      return;
    }

    if (path == null) {
      debugPrint('[Recording] stop returned null path');
      state = state.copyWith(
        status: RecordingStatus.error,
        error: 'Recording failed — no audio captured.',
      );
      return;
    }

    debugPrint('[Recording] handing off to Whisper…');
    try {
      final text = await _whisper.transcribe(path);
      debugPrint('[Recording] transcript: "$text"');
      state = state.copyWith(
        status: RecordingStatus.idle,
        transcript: text.isEmpty ? null : text,
        error: text.isEmpty ? 'No speech detected.' : null,
      );
    } catch (e, st) {
      debugPrint('[Recording] transcription error: $e\n$st');
      state = state.copyWith(
        status: RecordingStatus.error,
        error: 'Transcription failed: $e',
      );
    } finally {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
  }

  Future<void> cancelRecording() async {
    debugPrint('[Recording] cancelRecording() called — status: ${state.status}');
    // Reset state immediately so the UI responds at once.
    state = const RecordingState();
    try {
      final path = await _recorder.stop().timeout(
        const Duration(seconds: 4),
        onTimeout: () => _audioPath,
      );
      if (path != null) {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      }
    } catch (_) {
      // Ignore errors on cancel — the recorder may already be stopped.
    }
  }

  void clearTranscript() {
    state = state.copyWith(clearTranscript: true, clearError: true);
  }
}

final recordingProvider =
    NotifierProvider.autoDispose<RecordingNotifier, RecordingState>(
      RecordingNotifier.new,
    );
