import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'dart:async';

class VideoRecording {
  final String filePath;
  final Duration duration;
  final DateTime createdAt;

  VideoRecording({
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

enum VideoState { idle, initializing, ready, recording, paused, error }

class VideoViewModel extends BaseViewModel {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  VideoState _state = VideoState.idle;
  VideoState get state => _state;

  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;

  String get formattedDuration {
    final m = _recordingDuration.inMinutes.toString().padLeft(2, '0');
    final s = (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<VideoRecording> _recordings = [];
  List<VideoRecording> get recordings => _recordings;

  String _statusMessage = 'Initialize camera to start recording video';
  String get statusMessage => _statusMessage;

  bool _flashEnabled = false;
  bool get flashEnabled => _flashEnabled;

  Timer? _timer;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  bool get isReady => _state == VideoState.ready;
  bool get isRecording => _state == VideoState.recording;
  bool get isPaused => _state == VideoState.paused;
  bool get isInitializing => _state == VideoState.initializing;

  Future<void> initCamera() async {
    _state = VideoState.initializing;
    _statusMessage = 'Requesting permissions...';
    notifyListeners();

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      _state = VideoState.error;
      _statusMessage = 'Camera and microphone permissions required';
      notifyListeners();
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _state = VideoState.error;
        _statusMessage = 'No cameras available';
        notifyListeners();
        return;
      }

      _cameraController = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      _state = VideoState.ready;
      _statusMessage = 'Camera ready — tap record to start';
      notifyListeners();
    } catch (e) {
      _state = VideoState.error;
      _statusMessage = 'Camera init failed: $e';
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (_cameraController == null || !isReady) return;

    try {
      await _cameraController!.startVideoRecording();
      _state = VideoState.recording;
      _recordingDuration = Duration.zero;
      _statusMessage = 'Recording video...';
      notifyListeners();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
    } catch (e) {
      _statusMessage = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  Future<void> pauseRecording() async {
    if (!isRecording) return;
    try {
      await _cameraController!.pauseVideoRecording();
      _state = VideoState.paused;
      _timer?.cancel();
      _statusMessage = 'Recording paused';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Failed to pause: $e';
      notifyListeners();
    }
  }

  Future<void> resumeRecording() async {
    if (!isPaused) return;
    try {
      await _cameraController!.resumeVideoRecording();
      _state = VideoState.recording;
      _statusMessage = 'Recording...';
      notifyListeners();

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        notifyListeners();
      });
    } catch (e) {
      _statusMessage = 'Failed to resume: $e';
      notifyListeners();
    }
  }

  Future<void> stopRecording() async {
    if (!isRecording && !isPaused) return;
    _timer?.cancel();

    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'nexus_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedPath = path.join(dir.path, fileName);
      await File(file.path).copy(savedPath);

      _recordings.insert(
        0,
        VideoRecording(
          filePath: savedPath,
          duration: _recordingDuration,
          createdAt: DateTime.now(),
        ),
      );

      _state = VideoState.ready;
      _recordingDuration = Duration.zero;
      _statusMessage = 'Video saved successfully!';
      notifyListeners();
    } catch (e) {
      _state = VideoState.ready;
      _statusMessage = 'Failed to save video: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null) return;
    _flashEnabled = !_flashEnabled;
    await _cameraController!.setFlashMode(
      _flashEnabled ? FlashMode.torch : FlashMode.off,
    );
    notifyListeners();
  }

  void deleteRecording(int index) {
    _recordings.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}