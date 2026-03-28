import 'package:scanner/UI/audio/Audio_view.dart';
import 'package:scanner/UI/audio/Qrcode_view.dart';
import 'package:scanner/UI/fingerprint/fingerPrint_view.dart';
import 'package:scanner/UI/vidio/vidio_view.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import '../camera/camera_view.dart';


class HomeViewModel extends BaseViewModel {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<Widget> pages = const [
    CameraView(),
    FingerprintView(),
    AudioView(),
    VideoView(),
    QrScannerView(),
  ];

  final List<String> pageTitles = const [
    'CAMERA SCAN',
    'BIOMETRIC',
    'AUDIO REC',
    'VIDEO REC',
    'QR SCANNER',
  ];

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}