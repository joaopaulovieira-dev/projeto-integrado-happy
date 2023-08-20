import 'package:flutter/material.dart';

abstract class AppColors {
  Color get title;
  Color get button;
  Color get textSocialButton;
  Color get subTitle;
  Color get textWhite;
  Color get titleOnboarding1;
  Color get appBar;
  Color get backGround;
  Color get textBtnProximo;
  Color get titleFormCadastro;
  Color get divider;
  Color get subTitleFormCadastro;
  Color get textFormcadastro;
  Color get titleOrfanato;
  Color get titleDescricao;
  Color get titleBtnMapa;
  Color get titlediaVisita;
  Color get titlediaVisitaTrue;
  Color get titlediaVisitaFalse;
}

class AppColorsDefault implements AppColors {
  @override
  Color get title => const Color(0xffffffff);

  @override
  Color get subTitle => const Color(0xffffffff);

  @override
  Color get button => const Color(0xff666666);

  @override
  Color get textSocialButton => const Color(0xff004785);

  @override
  Color get textWhite => const Color(0xffffffff);

  @override
  Color get titleOnboarding1 => const Color(0xff15C3D6);

  @override
  Color get appBar => const Color(0xff8FA7B2);

  @override
  Color get backGround => const Color(0xFFf2f3f5);

  @override
  Color get textBtnProximo => const Color(0xFFFFFFFF);

  @override
  Color get titleFormCadastro => const Color(0xFF5C8599);

  @override
  Color get divider => const Color(0xFFD3E2E5);

  @override
  Color get subTitleFormCadastro => const Color(0xFF8FA7B2);

  @override
  Color get textFormcadastro => const Color(0xFF5C8599);

  @override
  Color get titleOrfanato => const Color(0xFF4D6F80);

  @override
  Color get titleDescricao => const Color(0xFF5C8599);

  @override
  Color get titleBtnMapa => const Color(0xFF0089A5);

  @override
  Color get titlediaVisita => const Color(0xFF5C8599);

  @override
  Color get titlediaVisitaTrue => const Color(0xFF37C77F);

  @override
  Color get titlediaVisitaFalse => const Color(0xFFFF669D);
}
