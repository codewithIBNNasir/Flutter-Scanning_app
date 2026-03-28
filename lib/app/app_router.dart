// GENERATED CODE - Manual router setup
// Run: flutter pub run build_runner build --delete-conflicting-outputs

import 'package:flutter/material.dart';
import 'package:scanner/UI/Home/home_view.dart';
import 'package:scanner/UI/audio/Audio_view.dart';
import 'package:scanner/UI/audio/Qrcode_view.dart';
import 'package:scanner/UI/camera/camera_view.dart';
import 'package:scanner/UI/fingerprint/fingerPrint_view.dart';
import 'package:scanner/UI/vidio/vidio_view.dart';


class Routes {
  static const String home = '/';
  static const String camera = '/camera';
  static const String fingerprint = '/fingerprint';
  static const String audio = '/audio';
  static const String video = '/video';
  static const String qrScanner = '/qr-scanner';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case Routes.camera:
        return MaterialPageRoute(builder: (_) => const CameraView());
      case Routes.fingerprint:
        return MaterialPageRoute(builder: (_) => const FingerprintView());
      case Routes.audio:
        return MaterialPageRoute(builder: (_) => const AudioView());
      case Routes.video:
        return MaterialPageRoute(builder: (_) => const VideoView());
      case Routes.qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerView());
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }
}