import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioRecordingData {
  final Duration duration;
  final double amplitude;

  const AudioRecordingData({
    required this.duration,
    required this.amplitude,
  });
}

abstract class AudioRecorderDataSource {
  Future<bool> requestPermission();
  Future<String> startRecording(String title);
  Future<String> stopRecording();
  void dispose();
  
  Stream<AudioRecordingData> get recordingStream;
}

class AudioRecorderDataSourceImpl implements AudioRecorderDataSource {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  StreamController<AudioRecordingData>? _recordingController;
  Timer? _recordingTimer;
  Duration _duration = Duration.zero;
  bool _isRecording = false;

  @override
  Stream<AudioRecordingData> get recordingStream {
    _recordingController ??= StreamController<AudioRecordingData>.broadcast();
    return _recordingController!.stream;
  }

  @override
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  @override
  Future<String> startRecording(String title) async {
    if (_isRecording) {
      throw Exception('Recording already in progress');
    }

    if (!await _recorder.hasPermission()) {
      if (!await requestPermission()) {
        throw Exception('Microphone permission denied');
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${directory.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final safeTitle = title.isEmpty ? 'Untitled' : title.replaceAll(' ', '_');
    _currentRecordingPath = '${recordingsDir.path}/${safeTitle}_$timestamp.m4a';

    _recordingController ??= StreamController<AudioRecordingData>.broadcast();

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );

    _isRecording = true;
    _duration = Duration.zero;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _duration = Duration(seconds: timer.tick);
      _recordingController?.add(AudioRecordingData(
        duration: _duration,
        amplitude: _getRandomAmplitude(),
      ));
    });

    return _currentRecordingPath!;
  }

  @override
  Future<String> stopRecording() async {
    if (!_isRecording) {
      throw Exception('No active recording to stop');
    }

    final path = await _recorder.stop();
    _recordingTimer?.cancel();
    _isRecording = false;

    // We do not close the stream so it can be reused later
    // _recordingController?.close();

    return path ?? _currentRecordingPath ?? '';
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingController?.close();
    _recorder.dispose();
  }

  double _getRandomAmplitude() {
    final random = DateTime.now().millisecond / 1000.0;
    final baseAmplitude = 0.3 + (random * 0.4); 
    final variation = (DateTime.now().microsecond % 100) / 1000.0;
    return (baseAmplitude + variation).clamp(0.0, 1.0);
  }
}
