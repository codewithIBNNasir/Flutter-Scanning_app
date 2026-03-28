import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';

enum CameraState { idle, initializing, ready, capturing, error }

class CameraViewModel extends BaseViewModel {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  CameraState _state = CameraState.idle;
  CameraState get state => _state;

  String? _capturedImagePath;
  String? get capturedImagePath => _capturedImagePath;

  String _statusMessage = 'Initialize camera to begin scanning';
  String get statusMessage => _statusMessage;

  bool _flashEnabled = false;
  bool get flashEnabled => _flashEnabled;

  int _cameraIndex = 0;
  List<CameraDescription> _cameras = [];

  bool get isReady => _state == CameraState.ready;
  bool get isCapturing => _state == CameraState.capturing;

  Future<void> initCamera() async {
    _setState(CameraState.initializing);
    _statusMessage = 'Requesting camera permissions...';
    notifyListeners();

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _setState(CameraState.error);
      _statusMessage = 'Camera permission denied';
      notifyListeners();
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _setState(CameraState.error);
        _statusMessage = 'No cameras found on device';
        notifyListeners();
        return;
      }

      _cameraController = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _setState(CameraState.ready);
      _statusMessage = 'Camera ready — tap to capture';
      notifyListeners();
    } catch (e) {
      _setState(CameraState.error);
      _statusMessage = 'Failed to initialize camera: $e';
      notifyListeners();
    }
  }

  Future<void> captureImage() async {
    if (_cameraController == null || !isReady) return;

    _setState(CameraState.capturing);
    _statusMessage = 'Capturing image...';
    notifyListeners();

    try {
      final XFile file = await _cameraController!.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'nexus_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(dir.path, fileName);

      await File(file.path).copy(savedPath);
      _capturedImagePath = savedPath;

      _setState(CameraState.ready);
      _statusMessage = 'Image captured successfully!';
      notifyListeners();
    } catch (e) {
      _setState(CameraState.error);
      _statusMessage = 'Capture failed: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFlash() async {
    if (_cameraController == null || !isReady) return;
    _flashEnabled = !_flashEnabled;
    await _cameraController!.setFlashMode(
      _flashEnabled ? FlashMode.torch : FlashMode.off,
    );
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _cameraController?.dispose();
    _setState(CameraState.initializing);
    notifyListeners();

    _cameraController = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    _setState(CameraState.ready);
    notifyListeners();
  }

  void clearCapture() {
    _capturedImagePath = null;
    notifyListeners();
  }

  void _setState(CameraState state) => _state = state;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}