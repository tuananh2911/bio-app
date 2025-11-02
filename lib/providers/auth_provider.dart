import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userName;
  String? _email;
  String? _phone;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get email => _email;
  String? get phone => _phone;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    _email = prefs.getString('email');
    _phone = prefs.getString('phone');
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    // TODO: Implement actual authentication logic
    // For now, using mock authentication
    if (username.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userName = username;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName!);
      
      // Load saved email and phone if available
      _email = prefs.getString('email');
      _phone = prefs.getString('phone');

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, String email) async {
    // TODO: Implement actual registration logic
    // For now, using mock registration
    if (username.isNotEmpty && password.isNotEmpty && email.isNotEmpty) {
      _isAuthenticated = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userName = username;
      _email = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', _userId!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('email', _email!);

      notifyListeners();
      return true;
    }
    return false;
  }
  
  Future<void> updateProfile({String? userName, String? email, String? phone}) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (userName != null) {
      _userName = userName;
      await prefs.setString('userName', userName);
    }
    
    if (email != null) {
      _email = email;
      await prefs.setString('email', email);
    }
    
    if (phone != null) {
      _phone = phone;
      await prefs.setString('phone', phone);
    }
    
    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userName = null;
    _email = null;
    _phone = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('email');
    await prefs.remove('phone');

    notifyListeners();
  }
}



