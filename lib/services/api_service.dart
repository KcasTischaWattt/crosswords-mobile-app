import 'package:crosswords/screens/auth_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ApiService {
  // TODO поменять на false
  static final bool useMock = false;
  static bool isAuthenticatedMock = false;

  /// Экземпляр Dio с предопределенными параметрами и перехватчиками
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
    if (navigatorKey.currentState?.canPop() == false) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => AuthPage(
            setLogin: () async {
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
  }

  /// Проверка аутентификацию
  static Future<bool> checkAuth() async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return isAuthenticatedMock;
    }

    try {
      await _dio.get("/users/check_auth");
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Логин пользователя
  static Future<void> login(String username, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      isAuthenticatedMock = true;
      return;
    }

    final response = await _dio.post("/users/login", data: {
      "username": username,
      "password": password,
    });

    if (response.statusCode != 200) {
      throw Exception("Login failed with status code ${response.statusCode}");
    }
  }

  /// Регистрация пользователя
  static Future<void> register(String name, String surname, String username,
      String email, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _dio.post(
      "/users/register",
      data: {
        "name": name,
        "surname": surname,
        "username": username,
        "email": email,
        "password": password,
      },
    );
  }

  /// Логаут
  static Future<void> logout() async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      isAuthenticatedMock = false;
      return;
    }

    try {
      await _dio.post("/users/logout");
    } catch (e) {
      print("Ошибка при выходе: $e");
    }
  }

  /// GET запрос к API
  static Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  /// POST запрос к API
  static Future<Response> post(
      String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }
}
