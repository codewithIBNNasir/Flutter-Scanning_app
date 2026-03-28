import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner/UI/Home/home_view.dart';
import 'package:scanner/UI/theme/app_theme.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app/app_router.dart';
import 'app/locator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080C14),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  setupLocator();

  runApp(const NexusScannerApp());
}

class NexusScannerApp extends StatelessWidget {
  const NexusScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXUS Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const HomeView(),
    );
  }
}