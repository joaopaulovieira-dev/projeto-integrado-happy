import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy/pages/cadastrar_evento/cadastrar_evento_page.dart';
import 'package:happy/pages/cadastrar_orfanato/cadastrar_orfanato_page.dart';
import 'package:happy/pages/home/home_page.dart';
import 'package:happy/pages/listar_evento/listar_evento.dart';
import 'package:happy/pages/login/login_page.dart';
import 'package:happy/pages/onboarding/onboarding_page.dart';
import 'pages/splash/splash_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'happy',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/onboarding': (context) => OnboardingPage(),
        '/cadastrar_orfanato': (context) => const CadastrarOrfanatoPage(),
        '/cadastrar_evento': (context) => const CadastrarEventoPage(),
        '/listar_evento': (context) => const ListarEventoPage(),
      },
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
