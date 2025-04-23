import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/models/article.dart';
import 'dart:io' show Directory;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // TODO поменять на false
  static final bool useMock = false;
  static bool isAuthenticatedMock = false;

  /// Экземпляр Dio с предопределенными параметрами и перехватчиками
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.62.162.108:8081",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );
  static final PersistCookieJar cookieJar = PersistCookieJar(
    storage: FileStorage('${Directory.systemTemp.path}/.cookies'),
  );
  static bool _interceptorsInitialized = false;

  static void initializeInterceptors() {
    if (_interceptorsInitialized) return;

    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(cookieJar));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        if (e.response?.statusCode == 401) {
          /// TODO перенаправить на страницу логина
          debugPrint("401 Unauthorized — пользователь неавторизован");
        }
        return handler.next(e);
      },
    ));

    _interceptorsInitialized = true;
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
  static Future<void> register(
      String name, String surname, String email, String password) async {
    if (useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _dio.post(
      "/users/register",
      data: {
        "name": name,
        "surname": surname,
        "username": email,
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
      debugPrint("Ошибка при выходе: $e");
    }
  }

  /// Получение списка статей
  static Future<List<Article>> fetchDocuments({
    required Map<String, dynamic> searchParams,
  }) async {
    final response = await _dio.post("/documents/search", data: searchParams);

    final List<dynamic> docsJson = response.data['documents'];
    return docsJson.map((json) => Article.fromJson(json)).toList();
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
