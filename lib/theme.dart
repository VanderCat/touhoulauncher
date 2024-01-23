import 'package:flutter/material.dart';

class NewMDDarkTheme {
  static const _1st   = Color(0xFFBB86FC);
  static const _1stvar= Color(0xFF3700B3);
  static const _2nd   = Color(0xFF03DAC6);
  static const _bg    = Color(0xFF121212);
  static const _err   = Color(0xFFCF6679);
  static const _onetc = Color(0xFF000000);
  static const _onbg  = Color(0xFFFFFFFF);
  static const _bar   = Color(0xFF272727);
  static const _card  = Color(0xFF1b1b1b);

  static final _base = ThemeData.dark();

  static ThemeData get theme => _base.copyWith(
      colorScheme: _base.colorScheme.copyWith(
        primary: _1st,
        primaryContainer: _1stvar,
        secondary: _1st,
        secondaryContainer: _1st,
        brightness: Brightness.dark,
        background: _bg,
        surface: _bg,
        error: _err,
        errorContainer: _err,
        onBackground: _onbg,
        onError: _onetc,
        onErrorContainer: _onetc,
        onPrimary: _onetc,
        onPrimaryContainer: _onetc,
        onSecondary: _onetc,
        onSecondaryContainer: _onetc,
        onSurface: _onbg,
        onSurfaceVariant: _onbg,
      ),
    backgroundColor: _bg,
    scaffoldBackgroundColor: _bg,
    appBarTheme: _base.appBarTheme.copyWith(
      backgroundColor: _bar,
    ),
    cardTheme: _base.cardTheme.copyWith(
      color: _card
    )
    );
}