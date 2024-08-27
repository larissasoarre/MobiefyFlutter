import 'package:flutter/material.dart';
import 'package:mobiefy_flutter/constants/colors.dart';

class AppFonts {
  AppFonts._();

  static const String headingFontFamily = 'Righteous';
  static const String textFontFamily = 'Roboto';

  static const TextStyle heading = TextStyle(
      fontFamily: headingFontFamily,
      fontSize: 47.0,
      decoration: TextDecoration.none,
      color: AppColors.black);

  static const TextStyle text = TextStyle(
      fontFamily: textFontFamily,
      fontWeight: FontWeight.w400,
      fontSize: 17.0,
      decoration: TextDecoration.none,
      color: AppColors.black);

  static const TextStyle inputLabel = TextStyle(
      fontFamily: textFontFamily,
      fontSize: 17.0,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.none,
      color: AppColors.black);
}
