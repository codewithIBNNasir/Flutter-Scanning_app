import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

enum QrState { idle, scanning, found, error }

class QrResult {
  final String value;
  final BarcodeFormat format;
  final DateTime scannedAt;

  QrResult({
    required this.value,
    required this.format,
    required this.scannedAt,
  });

  String get formatName => format.name.toUpperCase();
}

class QrScannerViewModel extends BaseViewModel {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  QrState _state = QrState.idle;
  QrState get state => _state;

  List<QrResult> _results = [];
  List<QrResult> get results => _results;

  QrResult? _lastResult;
  QrResult? get lastResult => _lastResult;

  String _statusMessage = 'Point camera at a QR code or barcode';
  String get statusMessage => _statusMessage;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _torchOn = false;
  bool get torchOn => _torchOn;

  bool _paused = false;
  bool get paused => _paused;

  void startScanning() {
    _isScanning = true;
    _paused = false;
    _state = QrState.scanning;
    _statusMessage = 'Scanning — align QR code within frame';
    scannerController.start();
    notifyListeners();
  }

  void stopScanning() {
    _isScanning = false;
    _state = QrState.idle;
    _statusMessage = 'Scanner paused';
    scannerController.stop();
    notifyListeners();
  }

  void onDetect(BarcodeCapture capture) {
    if (_paused) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;

      // Avoid duplicates within 2 seconds
      if (_lastResult != null &&
          _lastResult!.value == raw &&
          DateTime.now()
                  .difference(_lastResult!.scannedAt)
                  .inSeconds <
              2) continue;

      final result = QrResult(
        value: raw,
        format: barcode.format,
        scannedAt: DateTime.now(),
      );

      _lastResult = result;
      _results.insert(0, result);
      _state = QrState.found;
      _statusMessage = 'Code detected!';

      // Keep only last 20 results
      if (_results.length > 20) {
        _results = _results.sublist(0, 20);
      }

      notifyListeners();

      // Reset to scanning after a brief pause
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_isScanning) {
          _state = QrState.scanning;
          _statusMessage = 'Scanning — align QR code within frame';
          notifyListeners();
        }
      });

      break;
    }
  }

  void toggleTorch() {
    _torchOn = !_torchOn;
    scannerController.toggleTorch();
    notifyListeners();
  }

  void switchCamera() {
    scannerController.switchCamera();
    notifyListeners();
  }

  void clearResults() {
    _results.clear();
    _lastResult = null;
    notifyListeners();
  }

  void deleteResult(int index) {
    _results.removeAt(index);
    notifyListeners();
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }
}