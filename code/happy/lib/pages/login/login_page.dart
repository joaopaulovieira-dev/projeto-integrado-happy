// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:happy/pages/login/login_controller.dart';
import 'package:happy/pages/login/widgets/social_button.dart';
import 'package:happy/theme/app_gradients.dart';
import 'package:happy/theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import "dart:math";

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late VideoPlayerController _videoPlayerController;
  final controller = LoginController();

  @override
  void initState() {
    //Lista com os videos
    var list = [
      'assets/videos/1.mp4',
      'assets/videos/2.mp4',
      'assets/videos/3.mp4',
      'assets/videos/4.mp4',
      'assets/videos/5.mp4',
      'assets/videos/6.mp4'
    ];
    final random = Random(); //Random dos vídeos
    var element = list[random.nextInt(list.length)]; //Pega um vídeo aleatório

    super.initState();
    _videoPlayerController =
        VideoPlayerController.asset(element) //Inicia o vídeo
          ..initialize().then((context) {
            _videoPlayerController.play();
            _videoPlayerController.setLooping(true);
            setState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController.value.size.width,
                height: _videoPlayerController.value.size.height,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: CadastroGradient.linear,
            ),
            //Linhas
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo.png',
                        height: 75, // Adjust the height as needed
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.58,
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'Entre, existe um mundo de\nsorrisos esperando por você!',
                        style: AppTheme.textStyles.subTitle,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  SocialButtonWidget(
                    imagePhath: "assets/images/google.png",
                    label: 'Entrar com a conta Google',
                    onTap: () {
                      controller.googleSignIn(context);
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Ao entrar com Google você concorda com os ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                            text: 'Termos de Uso ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        TextSpan(
                          text: 'e a ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                            text: 'Política de Privacidade',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                        TextSpan(
                          text: '.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}
