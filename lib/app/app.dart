
import 'package:scanner/UI/Home/home_view.dart';
import 'package:scanner/UI/audio/Audio_view.dart';
import 'package:scanner/UI/audio/Qrcode_view.dart';
import 'package:scanner/UI/camera/camera_view.dart';
import 'package:scanner/UI/fingerprint/fingerPrint_view.dart';
import 'package:scanner/UI/vidio/vidio_view.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(routes: [
    MaterialRoute(page: HomeView, initial: true),
    MaterialRoute(page: CameraView),
    MaterialRoute(page: FingerprintView),
    MaterialRoute(page: AudioView),
    MaterialRoute(page: VideoView),
    MaterialRoute(page: QrScannerView),
  ],
    dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: SnackbarService),
  ],
  )
class App {}