import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _selectedLocaleKey = 'selected_locale';

  Locale? get locale => _locale;

  LocaleProvider() {
    loadLocale();
  }

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_selectedLocaleKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      _locale = const Locale('en'); // Default to English
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocaleKey, newLocale.languageCode);
    notifyListeners();
  }
}
