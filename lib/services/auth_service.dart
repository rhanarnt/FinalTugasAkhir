import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  static Future<void> saveLoginSession({String? name, String? email}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_isLoggedInKey, true);

    if (name != null && name.isNotEmpty) {
      await preferences.setString(_userNameKey, name);
    }

    if (email != null && email.isNotEmpty) {
      await preferences.setString(_userEmailKey, email);
    }
  }

  static Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_isLoggedInKey);
    await preferences.remove(_userNameKey);
    await preferences.remove(_userEmailKey);
  }
}
