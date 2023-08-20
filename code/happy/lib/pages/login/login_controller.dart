// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:happy/shared/auth/auth_controller.dart';
import 'package:happy/shared/models/user_model.dart';

class LoginController {
  final authController = AuthController();
  Future<void> googleSignIn(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    try {
      final response = await googleSignIn.signIn();
      final user = UserModel(
        name: response!.displayName!,
        email: response.email,
        uid: response.id,
        photoURL: response.photoUrl,
      );
      authController.setUser(context, user);
      if (kDebugMode) {
        print(response);
      }
    } catch (error) {
      authController.setUser(context, null);
      if (kDebugMode) {
        print(error);
      }
    }
  }
}
