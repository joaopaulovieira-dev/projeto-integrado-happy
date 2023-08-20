// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:happy/shared/auth/auth_controller.dart';
import 'package:happy/theme/app_gradients.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _loadSplash();
  }

  Future<void> _loadSplash() async {
    await Future.delayed(const Duration(seconds: 3));
    final authController = AuthController();
    authController.currentUser(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SplashPageGradient.linear,
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 180, // Adjust the width as needed
            height: 163, // Adjust the height as needed
          ),
        ),
      ),
    );
  }
}
