import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  late Box<AppSettings> _box;
  late AppSettings _settings;

  AppSettings get settings => _settings;

  SettingsProvider() {
    _init();
  }

  void _init() async {
    // Assuming Hive.initFlutter() and registerAdapter are called in main.dart
    // and the box is opened there or we ensure it's open here.
    // Ideally, main.dart should await Hive.openBox('settings').
    if (Hive.isBoxOpen('settings')) {
      _box = Hive.box<AppSettings>('settings');
    } else {
      _box = await Hive.openBox<AppSettings>('settings');
    }
    
    if (_box.isEmpty) {
      _settings = AppSettings(
        apiKey: "",
        baseUrl: "https://api.openai.com",
        model: "gpt-3.5-turbo",
        temperature: 0.7,
        fontSize: 14.0,
      );
      await _box.put('config', _settings);
    } else {
      _settings = _box.get('config')!;
    }
    notifyListeners();
  }

  void _save() {
    _settings.save(); // HiveObject extension method
    notifyListeners();
  }

  void updateApiKey(String val) { 
    _settings.apiKey = val; 
    _save(); 
  }

  void updateBaseUrl(String val) { 
    _settings.baseUrl = val; 
    _save(); 
  }

  void updateModel(String val) { 
    _settings.model = val; 
    _save(); 
  }

  void updateTemperature(double val) { 
    _settings.temperature = val; 
    _save(); 
  }

  void updateFontSize(double val) { 
    _settings.fontSize = val; 
    _save(); 
  }

  void updateBackgroundImage(String? path) {
    _settings.backgroundImagePath = path;
    _save();
  }

  void updateUserAvatar(String? path) {
    _settings.userAvatarPath = path;
    _save();
  }

  void updateSystemPrompt(String val) {
    _settings.systemPrompt = val;
    _save();
  }

  void updateHistoryCount(int val) {
    _settings.historyCount = val;
    _save();
  }
}
