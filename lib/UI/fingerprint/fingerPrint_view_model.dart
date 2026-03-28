import 'package:local_auth/local_auth.dart';
import 'package:stacked/stacked.dart';

enum FingerprintState {
  idle,
  scanning,
  success,
  failure,
  unavailable,
}

class FingerprintViewModel extends BaseViewModel {
  final LocalAuthentication _auth = LocalAuthentication();

  FingerprintState _state = FingerprintState.idle;
  FingerprintState get state => _state;

  String _statusMessage = 'Tap scan to authenticate with biometrics';
  String get statusMessage => _statusMessage;

  bool _biometricAvailable = false;
  bool get biometricAvailable => _biometricAvailable;

  List<BiometricType> _availableBiometrics = [];
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  int _scanCount = 0;
  int get scanCount => _scanCount;

  bool _lastAuthResult = false;
  bool get lastAuthResult => _lastAuthResult;

  bool get isScanning => _state == FingerprintState.scanning;
  bool get isSuccess => _state == FingerprintState.success;
  bool get isFailure => _state == FingerprintState.failure;

  Future<void> checkBiometrics() async {
    try {
      _biometricAvailable = await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();
      _availableBiometrics = await _auth.getAvailableBiometrics();

      if (!_biometricAvailable) {
        _state = FingerprintState.unavailable;
        _statusMessage = 'Biometric authentication not available on this device';
      } else {
        _statusMessage = 'Biometrics available — tap scan to authenticate';
      }
      notifyListeners();
    } catch (e) {
      _state = FingerprintState.unavailable;
      _statusMessage = 'Error checking biometrics: $e';
      notifyListeners();
    }
  }

  Future<void> authenticate() async {
    if (isScanning) return;

    _state = FingerprintState.scanning;
    _statusMessage = 'Scanning biometric...';
    notifyListeners();

    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate with NEXUS Scanner',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      _scanCount++;
      _lastAuthResult = authenticated;

      if (authenticated) {
        _state = FingerprintState.success;
        _statusMessage = 'Authentication successful!';
      } else {
        _state = FingerprintState.failure;
        _statusMessage = 'Authentication failed or cancelled';
      }

      notifyListeners();

      // Reset to idle after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      if (_state != FingerprintState.scanning) {
        _state = FingerprintState.idle;
        _statusMessage = 'Tap scan to authenticate again';
        notifyListeners();
      }
    } catch (e) {
      _scanCount++;
      _state = FingerprintState.failure;
      _statusMessage = 'Authentication error: ${e.toString().split(':').first}';
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      _state = FingerprintState.idle;
      notifyListeners();
    }
  }

  void reset() {
    _state = FingerprintState.idle;
    _statusMessage = 'Tap scan to authenticate with biometrics';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}