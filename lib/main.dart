import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'screens/loginScreen.dart';
import 'screens/registerScreen.dart';
import 'screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

// In your main.dart or splash screen
class AppVersionCheck {
  static const String currentVersion = '1.0.1'; // Match codemagic build number
  
  static Future<void> checkVersion(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('https://hometutorhub.in/api/app_version'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'];
        
        if (latestVersion != currentVersion) {
          _showUpdateDialog(context);
        }
      }
    } catch (e) {
      print('Version check failed: $e');
    }
  }
  
  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Update Available'),
        content: Text('A new version is available. Please update to continue.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Open Play Store or direct download
              final url = Platform.isAndroid
                  ? 'https://play.google.com/store/apps/details?id=com.hometutorhub.app'
                  : 'https://apps.apple.com/app/...';
              launchUrl(Uri.parse(url));
            },
            child: Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeTutorHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
