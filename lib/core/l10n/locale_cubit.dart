import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _key = 'app_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs)
      : super(Locale(_prefs.getString(_key) ?? 'sr'));

  void setLocale(Locale locale) {
    _prefs.setString(_key, locale.languageCode);
    emit(locale);
  }

  void toggle() {
    final next = state.languageCode == 'sr'
        ? const Locale('en')
        : const Locale('sr');
    setLocale(next);
  }
}
