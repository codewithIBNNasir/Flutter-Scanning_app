import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:stacked/stacked.dart';

class AudioRecording {
  final String filePath;
  final Duration duration;
  final DateTime createdAt;

  AudioRecording({
    required this.filePath,
    required this.duration,
    required this.createdAt,
  });

  String get fileName => path.basename(filePath);
  String get formattedDuration {
    final m = duration.inMinutes.toString().padLeft(2, '0');
    final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class AudioViewModel extends BaseViewModel {
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;

  String get formattedDuration {
    final m = _recordingDuration.inMinutes.toString().padLeft(2, '0');
    final s = (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double _amplitude = 0.0;
  double get amplitude => _amplitude;

  List<double> _waveformBars = List.filled(40, 0.0);
  List<double> get waveformBars => _waveformBars;

  List<AudioRecording> _recordings = [];
  List<AudioRecording> get recordings => _recordings;

  String _statusMessage = 'Tap record to start capturing audio';
  String get statusMessage => _statusMessage;

  Timer? _durationTimer;
  Timer? _amplitudeTimer;
  String? _currentFilePath;

  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _statusMessage = 'Microphone permission denied';
      notifyListeners();
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'nexus_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentFilePath = path.join(dir.path, fileName);

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentFilePath!,
      );

      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _statusMessage = 'Recording...';
      notifyListeners();

      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });

      _amplitudeTimer =
          Timer.periodic(const Duration(milliseconds: 100), (_) async {
        final amp = await _recorder.getAmplitude();
        _amplitude = (amp.current + 60) / 60;
        if (_amplitude < 0) _amplitude = 0;
        if (_amplitude > 1) _amplitude = 1;

        // Update waveform
        _waveformBars = [
          ..._waveformBars.skip(1),
          _amplitude,
        ];
        notifyListeners();
      });
    } catch (e) {
      _statusMessage = 'Error starting recording: $e';
      notifyListeners();
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording) return;
    await _recorder.pause();
    _isPaused = true;
    _durationTimer?.cancel();
    _amplitudeTimer?.cancel();
    _statusMessage = 'Recording paused';
    notifyListeners();
  }

  Future<void> resumeRecording() async {
    if (!_isPaused) return;
    await _recorder.resume();
    _isPaused = false;
    _statusMessage = 'Recording...';
    notifyListeners();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recordingDuration += const Duration(seconds: 1);
      notifyListeners();
    });

    _amplitudeTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) async {
      final amp = await _recorder.getAmplitude();
      _amplitude = (amp.current + 60) / 60;
      if (_amplitude < 0) _amplitude = 0;
      if (_amplitude > 1) _amplitude = 1;
      _waveformBars = [..._waveformBars.skip(1), _amplitude];
      notifyListeners();
    });
  }

  Future<void> stopRecording() async {
    if (!_isRecording) return;

    _durationTimer?.cancel();
    _amplitudeTimer?.cancel();

    final filePath = await _recorder.stop();
    _isRecording = false;
    _isPaused = false;

    if (filePath != null) {
      _recordings.insert(
        0,
        AudioRecording(
          filePath: filePath,
          duration: _recordingDuration,
          createdAt: DateTime.now(),
        ),
      );
      _statusMessage = 'Recording saved!';
    } else {
      _statusMessage = 'Recording failed to save';
    }

    _amplitude = 0;
    _waveformBars = List.filled(40, 0.0);
    _recordingDuration = Duration.zero;
    notifyListeners();
  }

  void deleteRecording(int index) {
    _recordings.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}