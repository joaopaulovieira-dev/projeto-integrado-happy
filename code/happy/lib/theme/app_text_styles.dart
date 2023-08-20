import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy/theme/app_theme.dart';

abstract class ApptextStyles {
  TextStyle get titleSplashPage;
  TextStyle get subTitleSplashPage;
  TextStyle get title;
  TextStyle get subTitle;
  TextStyle get button;
  TextStyle get titleOnboarding1;
  TextStyle get titleOnboarding2;
  TextStyle get appBar;
  TextStyle get btnProximo;
  TextStyle get titleFormCadastro;
  TextStyle get subTitleFormCadastro;
  TextStyle get subTitleFormCadastroMaxCharacters;
  TextStyle get titleOrfanato;
  TextStyle get titleDescricao;
  TextStyle get titleBtnMapa;
  TextStyle get titleInstruVisita;
  TextStyle get titleWhatsapp;
  TextStyle get titlediaVisita;
  TextStyle get titlediaVisitaTrue;
  TextStyle get titlediaVisitaFalse;
}

class ApptextStylesDefault implements ApptextStyles {
  @override
  TextStyle get titleSplashPage => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.title,
      );
  @override
  TextStyle get subTitleSplashPage => GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w300,
        color: AppTheme.colors.subTitle,
      );

  @override
  TextStyle get title => GoogleFonts.nunito(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.title,
      );
  @override
  TextStyle get subTitle => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.subTitle,
      );

  @override
  TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.colors.textSocialButton,
      );

  @override
  TextStyle get titleOnboarding1 => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleOnboarding1,
        height: 1.0,
      );

  @override
  TextStyle get titleOnboarding2 => GoogleFonts.nunito(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleOnboarding1,
        height: 1.0,
      );

  @override
  TextStyle get appBar => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.colors.appBar,
      );

  @override
  TextStyle get btnProximo => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.textBtnProximo,
      );

  @override
  TextStyle get titleFormCadastro => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleFormCadastro,
      );
  @override
  TextStyle get subTitleFormCadastro => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppTheme.colors.subTitleFormCadastro,
      );

  @override
  TextStyle get subTitleFormCadastroMaxCharacters => GoogleFonts.nunito(
        fontSize: 12,
        //fontWeight: FontWeight.w500,
        color: AppTheme.colors.subTitleFormCadastro,
      );
  @override
  TextStyle get titleOrfanato => GoogleFonts.nunito(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleOrfanato,
      );

  @override
  TextStyle get titleDescricao => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.colors.titleDescricao,
      );

  @override
  TextStyle get titleBtnMapa => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleBtnMapa,
      );

  @override
  TextStyle get titleInstruVisita => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.colors.titleDescricao,
      );

  @override
  TextStyle get titleWhatsapp => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  @override
  TextStyle get titlediaVisita => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.colors.titlediaVisita,
      );

  @override
  TextStyle get titlediaVisitaTrue => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.colors.titlediaVisitaTrue,
      );

  @override
  TextStyle get titlediaVisitaFalse => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.colors.titlediaVisitaFalse,
      );
}
