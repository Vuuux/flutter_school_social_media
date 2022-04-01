import 'package:eventual/eventual-notifier.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';
  static EventualNotifier<ThemeMode> themeNotifier =
      EventualNotifier(ThemeMode.dark);
  bool _loadThemeFromBox() => _box.read(_key) ?? false;
  void _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);
  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkTheme => _loadThemeFromBox();
  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
    themeNotifier.value =
        !_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark;
    themeNotifier.notifyChange();
  }
}
