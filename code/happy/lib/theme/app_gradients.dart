import 'package:flutter/material.dart';

class SplashPageGradient {
  static const linear = LinearGradient(
    colors: [
      Color(0xFF2AB5D1),
      Color(0xFF00C7C7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class CadastroGradient {
  static const linear = LinearGradient(
    colors: [
      Color.fromRGBO(42, 181, 209, 0.350),
      Color.fromRGBO(0, 199, 199, 1.000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
