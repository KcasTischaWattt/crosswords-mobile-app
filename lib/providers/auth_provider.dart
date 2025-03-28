import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _showMainApp = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get showMainApp => _showMainApp;

  Future<void> checkAuth() async {
    _isAuthenticated = await ApiService.checkAuth();
    _showMainApp = _isAuthenticated;
    notifyListeners();
  }

  void setUnauthenticated() {
    _isAuthenticated = false;
    _showMainApp = false;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    _showMainApp = true;
    notifyListeners();
  }

  void continueWithoutLogin() {
    _isAuthenticated = false;
    _showMainApp = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    _showMainApp = false;
    notifyListeners();
  }
}
