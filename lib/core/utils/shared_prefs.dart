import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _ownerTokenKey = 'owner_token';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // SYNCHRONOUS — bisa dipanggil langsung tanpa await
  static String? getOwnerToken() => _prefs?.getString(_ownerTokenKey);
  static String? getToken() => _prefs?.getString(_tokenKey);
  static String? getRole() => _prefs?.getString(_roleKey);

  // ASYNC untuk menyimpan
  static Future<void> saveOwnerToken(String token) async {
    await _prefs?.setString(_ownerTokenKey, token);
  }

  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  static Future<void> saveRole(String role) async {
    await _prefs?.setString(_roleKey, role);
  }

  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  static bool isLoggedIn() => getToken() != null && getToken()!.isNotEmpty;
}