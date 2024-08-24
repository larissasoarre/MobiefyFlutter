import 'package:flutter/material.dart';

class Fonts {
  Fonts._();

  static const String headingFontFamily = 'Righteous';
  static const String textFontFamily = 'Roboto';

  static const TextStyle heading = TextStyle(
    fontFamily: headingFontFamily,
    fontSize: 47.0,
  );

  static const TextStyle text = TextStyle(
    fontFamily: textFontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 17.0,
  );
}
