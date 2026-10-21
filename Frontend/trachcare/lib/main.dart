import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:sizer/sizer.dart';
import 'package:toastification/toastification.dart';
import 'package:trachcare/Screens/AuthScreens/SplashScreen.dart';
import 'package:trachcare/services/reminder_service.dart';
import 'package:trachcare/style/design_system.dart';
import 'package:trachcare/style/responsive.dart';

/// Escape hatch for a backend whose TLS certificate cannot be bundled, e.g.
/// `--dart-define=ALLOW_INSECURE_TLS=true`. Off by default, so a release build
/// never silently trusts a bad certificate.
const allowInsecureTls = bool.fromEnvironment('ALLOW_INSECURE_TLS');

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              !kReleaseMode || allowInsecureTls;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // Necessary initialization for package:media_kit.
  MediaKit.ensureInitialized();

  // Arms the patient's daily message schedule against whatever was saved on
  // the last run, so reminders keep arriving without opening the app first.
  // A reminder failure must never block the app from starting.
  try {
    await ReminderService.instance.init();
  } catch (e) {
    debugPrint('ReminderService unavailable: $e');
  }

  runApp(ToastificationWrapper(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      final media = MediaQuery.of(context);
      AppSize.init(media.size, media.devicePixelRatio);
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen());
    });
  }
}
