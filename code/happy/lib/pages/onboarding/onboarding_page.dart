import 'package:flutter/material.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  final introKey = GlobalKey<IntroductionScreenState>();

  OnboardingPage({super.key});

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: const Color(0xFFEBF2F5),
      pages: [
        PageViewModel(
          titleWidget: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 40.0),
            child: Text(
              "Leve felicidade para o mundo",
              style: AppTheme.textStyles.titleOnboarding1,
            ),
          ),
          bodyWidget: const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 40.0),
            child: Text(
              "Visite orfanatos e mude o dia dessas crianças.",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF5C8599),
              ),
            ),
          ),
          image: Padding(
            padding: const EdgeInsets.only(top: 90.0),
            child: Image.asset(
              'assets/images/onboarding1.png',
            ),
          ),
          decoration: const PageDecoration(
            pageColor: Color(0xFFEBF2F5),
          ),
        ),
        PageViewModel(
          titleWidget: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Image.asset(
              'assets/images/onboarding2.png',
              width: 295,
              height: 488,
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 20.0),
            child: Text(
              "Escolha um\norfanato no mapa e faça uma visita",
              style: AppTheme.textStyles.titleOnboarding2,
              textAlign: TextAlign.right,
            ),
          ),
          decoration: const PageDecoration(
            pageColor: Color(0xFFEBF2F5),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: false, // Pular
      showNextButton: true, // Próximo
      next: Image.asset('assets/images/botao1.png', width: 56, height: 56),
      done: Image.asset('assets/images/botao1.png', width: 56, height: 56),
      curve: Curves.easeInOut, // Curva de animação
      controlsPadding: const EdgeInsets.all(16.0),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: const Color(0xFFFFD666), // Cor dos pontos ativos
        color: const Color(0xFFF2DAAA), // Cor dos pontos inativos
        spacing: const EdgeInsets.symmetric(horizontal: 5.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }
}
