import 'package:crosswords/screens/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8081",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  )..interceptors.add(InterceptorsWrapper(
    onError: (DioException e, ErrorInterceptorHandler handler) {
      if (e.response?.statusCode == 401) {
        _handleUnauthorized();
      }
      return handler.next(e);
    },
  ));

  /// Перенаправляем пользователя на экран логина при 401
  static void _handleUnauthorized() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onLogin: () async {
            navigatorKey.currentState?.pushReplacementNamed('/main');
          },
          onContinueWithoutLogin: () {
            navigatorKey.currentState?.pushReplacementNamed('/main');
          },
          toggleTheme: () {},
          isDarkMode: false,
        ),
      ),
          (route) => false,
    );
  }

  /// GET запрос к API
  static Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  /// POST запрос к API
  static Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }
}
