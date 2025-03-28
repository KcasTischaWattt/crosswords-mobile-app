import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    _isAuthenticated = await ApiService.checkAuth();
    notifyListeners();
  }

  void setUnauthenticated() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}