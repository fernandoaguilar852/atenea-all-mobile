import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static const String _cacheBox = 'cache_box';
  static const String _settingsBox = 'settings_box';

  // Initialize Hive boxes
  Future<void> init() async {
    await Hive.openBox(_cacheBox);
    await Hive.openBox(_settingsBox);
  }

  // Cache Box
  Box get _cache => Hive.box(_cacheBox);

  Future<void> saveToCache(String key, dynamic value) async {
    await _cache.put(key, value);
  }

  dynamic getFromCache(String key) {
    return _cache.get(key);
  }

  Future<void> removeFromCache(String key) async {
    await _cache.delete(key);
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }

  // Settings Box
  Box get _settings => Hive.box(_settingsBox);

  Future<void> saveSetting(String key, dynamic value) async {
    await _settings.put(key, value);
  }

  dynamic getSetting(String key) {
    return _settings.get(key);
  }

  Future<void> removeSetting(String key) async {
    await _settings.delete(key);
  }

  Future<void> clearSettings() async {
    await _settings.clear();
  }

  // Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }
}
