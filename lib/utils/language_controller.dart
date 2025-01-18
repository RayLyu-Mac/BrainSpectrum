import 'package:flutter/material.dart';

class LanguageController extends ChangeNotifier {
  bool _isChinese = false;

  LanguageController() {
    // Initialize with system locale
    final systemLocale = WidgetsBinding.instance.window.locale.languageCode;
    _isChinese = systemLocale == 'zh';
  }

  bool get isChinese => _isChinese;

  void toggleLanguage() {
    _isChinese = !_isChinese;
    notifyListeners();
  }

  String getText(String englishText, String chineseText) {
    return _isChinese ? chineseText : englishText;
  }
}
