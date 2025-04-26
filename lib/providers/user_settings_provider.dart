import 'package:dio/dio.dart';

import '../services/api_service.dart';
import 'package:flutter/material.dart';

class UserSettingsProvider extends ChangeNotifier {
  bool subscribable = false;
  bool sendToMail = false;
  bool mobileNotifications = false;
  bool personalSendToMail = false;
  bool personalMobileNotifications = false;

  bool isLoading = false;
  bool isPasswordChanging = false;
  bool isEmailChanging = false;

  Future<void> loadSettings() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await ApiService.get('/users/personal_info');
      subscribable = response.data['subscribable'];
      sendToMail = response.data['send_to_mail'];
      mobileNotifications = response.data['mobile_notifications'];
      personalSendToMail = response.data['personal_send_to_mail'];
      personalMobileNotifications =
          response.data['personal_mobile_notifications'];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings() async {
    await ApiService.put('/users/subscription_settings/set', data: {
      'subscribable': subscribable,
      'send_to_mail': sendToMail,
      'mobile_notifications': mobileNotifications,
      'personal_send_to_mail': personalSendToMail,
      'personal_mobile_notifications': personalMobileNotifications,
    });
  }

  void setSubscribable(bool value) {
    subscribable = value;
    notifyListeners();
    updateSettings();
  }

  void setSendToMail(bool value) {
    sendToMail = value;
    notifyListeners();
    updateSettings();
  }

  void setMobileNotifications(bool value) {
    mobileNotifications = value;
    notifyListeners();
    updateSettings();
  }

  void setPersonalSendToMail(bool value) {
    personalSendToMail = value;
    notifyListeners();
    updateSettings();
  }

  void setPersonalMobileNotifications(bool value) {
    personalMobileNotifications = value;
    notifyListeners();
    updateSettings();
  }

  /// Смена пароля пользователя
  Future<String?> changePassword(String oldPassword, String newPassword) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return 'Пожалуйста, заполните все поля.';
    }
    try {
      isPasswordChanging = true;
      notifyListeners();
      await ApiService.changePassword(oldPassword, newPassword);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return 'Новый пароль не должен совпадать со старым.';
      } else if (e.response?.statusCode == 403) {
        return 'Старый пароль неверный.';
      } else {
        return 'Не удалось изменить пароль. Попробуйте позже.';
      }
    } catch (e) {
      return 'Произошла непредвиденная ошибка.';
    } finally {
      isPasswordChanging = false;
      notifyListeners();
    }
  }

  Future<String?> changeEmail(String newEmail) async {
    if (newEmail.isEmpty) {
      return 'Пожалуйста, заполните поле почты.';
    }
    try {
      isEmailChanging = true;
      notifyListeners();
      await ApiService.changeEmail(newEmail);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return 'Новый email не должен совпадать со старым';
      } else {
        return 'Не удалось изменить почту. Попробуйте позже.';
      }
    } catch (e) {
      return 'Произошла непредвиденная ошибка.';
    } finally {
      isEmailChanging = false;
      notifyListeners();
    }
  }
}
