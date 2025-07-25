import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/chat/chat_consultation.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';

// Geçici placeholder widgetlar
class CameraCapture extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class SkinAnalysisHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class AnalysisResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class ProfileSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container();
}

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String cameraCapture = '/camera-capture';
  static const String chatConsultation = '/chat-consultation';
  static const String skinAnalysisHistory = '/skin-analysis-history';
  static const String dashboard = '/dashboard';
  static const String analysisResults = '/analysis-results';
  static const String profileSettings = '/profile-settings';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => SplashScreen(),
    login: (context) => LoginScreen(),
    cameraCapture: (context) => CameraCapture(),
    chatConsultation: (context) => ChatConsultation(),
    skinAnalysisHistory: (context) => SkinAnalysisHistory(),
    dashboard: (context) => HomeScreen(),
    analysisResults: (context) => AnalysisResults(),
    profileSettings: (context) => ProfileSettings(),
    '/home': (context) => HomeScreen(),
  };
}
