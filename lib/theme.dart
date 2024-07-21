import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData themeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 0, 23, 172),
  ),
  splashFactory: NoSplash.splashFactory,
  // textTheme: GoogleFonts.exoTextTheme(),
  textTheme: GoogleFonts.gafataTextTheme(),
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
);
