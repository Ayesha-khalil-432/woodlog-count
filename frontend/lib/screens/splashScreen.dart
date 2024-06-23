import 'package:flutter/material.dart';
import 'package:frontend/Storage/secureStorage.dart';
import 'package:frontend/screens/WelcomeScreen.dart';
import 'package:frontend/screens/adminLandingPage.dart';
import 'package:frontend/screens/officerImageUploadingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? accessToken = await SecureStorage().readSecureData('accessToken');
    // print(' access $accessToken');
    if (accessToken != null && accessToken.isNotEmpty) {
      String? currentRole =
          await SecureStorage().readSecureData('currentRoleOfUser');
      // print(' current role $currentRole');
      if (currentRole != null && currentRole == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminLandingPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UploadScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:
            CircularProgressIndicator(), // Loading indicator while checking login status
      ),
    );
  }
}
