import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();
  static const _notesKey = 'encrypted_notes';
  static const _pinHashKey = 'pin_hash';
  static const _themeModeKey = 'theme_mode';

  // Save encrypted notes as JSON string
  static Future<void> saveNotes(String encryptedJson) async {
    await _storage.write(key: _notesKey, value: encryptedJson);
  }

  static Future<String?> loadNotes() async {
    return await _storage.read(key: _notesKey);
  }

  // Save hashed PIN (never store raw PIN)
  static Future<void> savePinHash(String hash) async {
    await _storage.write(key: _pinHashKey, value: hash);
  }

  static Future<String?> loadPinHash() async {
    return await _storage.read(key: _pinHashKey);
  }

  static Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(key: _themeModeKey, value: themeMode);
  }

  static Future<String?> loadThemeMode() async {
    return await _storage.read(key: _themeModeKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
