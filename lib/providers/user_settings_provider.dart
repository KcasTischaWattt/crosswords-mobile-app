import '../services/api_service.dart';
import 'package:flutter/material.dart';

class UserSettingsProvider extends ChangeNotifier {
  bool subscribable = false;
  bool sendToMail = false;
  bool mobileNotifications = false;
  bool personalSendToMail = false;
  bool personalMobileNotifications = false;

  bool isLoading = false;

  Future<void> loadSettings() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await ApiService.get('/users/personal_info');
      subscribable = response.data['subscribable'];
      sendToMail = response.data['send_to_mail'];
      mobileNotifications = response.data['mobile_notifications'];
      personalSendToMail = response.data['personal_send_to_mail'];
      personalMobileNotifications = response.data['personal_mobile_notifications'];
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
}