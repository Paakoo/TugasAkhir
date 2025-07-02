import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  Future<void> checkToken() async {
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay
    
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        navigateToLogin();
      } else {
        navigateToHome();
      }
    } catch (e) {
      navigateToLogin();
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void navigateToHome() {
    Navigator.pushReplacementNamed(context, '/cob');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/image.png', // Add your logo asset
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}