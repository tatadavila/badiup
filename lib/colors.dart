import 'package:flutter/material.dart';

// 25/10/2019 Yamaguchi san and Ishikawa san agreed upon
// - 0xFF386150 for text color
// - 0xFF231F20 for primary color
// - 0xFFB22323 for delete icon color
// - 0xFFBABABA for spacer color

const kPaletteDeepPurple = const Color(0xFF231F20);
const kPaletteWhite = Colors.white;
const kPalettePurple = const Color(0xFF386150);
const kPalettePurple100 = const Color(0xFFE1BEE7);
const kPaletteRed = Colors.red;
const kPaletteBorderColor = const Color(0xFF8D99AE);
const kPaletteDeleteIconColor = const Color(0xFFB22323);
const kPaletteSpacerColor = const Color(0xFFBABABA);
const paletteBlackColor = const Color(0xFF151515);
const paletteLightGreyColor = const Color(0xFFD2D1D1);
const paletteDarkRedColor = const Color(0xFF892C26);
const paletteForegroundColor = const Color(0xFF892C26);
const paletteDarkGreyColor = const Color(0xFF8D8D8D);
const paletteRoseColor = const Color(0xFFF5D8D6);

TextStyle getAlertStyle() {
  return TextStyle(
    color: paletteForegroundColor,
    fontWeight: FontWeight.bold,
  );
}
