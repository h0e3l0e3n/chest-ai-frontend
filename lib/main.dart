import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screens.dart';
import 'welcome_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final bool hasRole = prefs.getString('userRole') != null;

  Widget initialScreen;
  if (isLoggedIn && hasRole) {
    initialScreen = const DashboardScreen();
  } else if (isLoggedIn && !hasRole) {
    initialScreen = const WelcomeScreen();
  } else {
    initialScreen = const AuthSelectionScreen();
  }

  runApp(MediScanApp(initialScreen: initialScreen));
}

class MediScanApp extends StatelessWidget {
  final Widget initialScreen;
  
  const MediScanApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: initialScreen,
    );
  }
}