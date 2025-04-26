import 'package:crosswords/data/constants/filter_constants.dart';
import 'package:crosswords/providers/abstract/filter_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/models/subscribe_options.dart';
import '../services/api_service.dart';

class SubscriptionProvider extends ChangeNotifier implements FilterProvider {
  final List<Subscription> _subscriptions = [];
  String _currentUserEmail = '';

  int? _selectedSubscriptionId;
  bool _isLoading = false;
  String _selectedCategory = "Все дайджесты";

  List<String> _selectedSources = [];
  List<String> _selectedTags = [];
  String _title = '';
  String _description = '';
  List<String> _followers = [];
  String _owner = '';
  bool _sendToMail = false;
  bool _mobileNotifications = false;
  bool _isPublic = false;
  String _currentFollowerInput = '';
  bool _isCreating = false;

  bool get isLoading => _isLoading;

  int? get selectedSubscriptionId => _selectedSubscriptionId;

  String get currentUserEmail => _currentUserEmail;

  List<Subscription> get subscriptions => _subscriptions;

  @override
  List<String> get selectedSources => _selectedSources;

  @override
  List<String> get selectedTags => _selectedTags;

  @override
  List<String> get sources => defaultSources;

  @override
  List<String> get tags => defaultTags;

  bool get sendToMail => _sendToMail;

  bool get mobileNotifications => _mobileNotifications;

  bool get isPublic => _isPublic;

  String get title => _title;

  String get description => _description;

  String get owner => _owner;

  List<String> get followers => _followers;

  String get currentFollowerInput => _currentFollowerInput;

  String get selectedCategory => _selectedCategory;

  bool get isCreating => _isCreating;

  List<Subscription> get filteredSubscriptions {
    if (_selectedCategory == "Все дайджесты") {
      return _subscriptions;
    } else if (_selectedCategory == "Подписки") {
      return _subscriptions
          .where((sub) => sub.subscribeOptions.subscribed)
          .toList();
    } else if (_selectedCategory == "Приватные") {
      return _subscriptions.where((sub) => !sub.public).toList();
    }
    return _subscriptions;
  }

  void setSelectedSubscription(int? subscriptionId) {
    _selectedSubscriptionId = subscriptionId;
    notifyListeners();
  }

  void resetSelectedSubscription() {
    _selectedSubscriptionId = null;
    notifyListeners();
  }

  void setSendToMail(bool value) {
    _sendToMail = value;
    notifyListeners();
  }

  void setMobileNotifications(bool value) {
    _mobileNotifications = value;
    notifyListeners();
  }

  void setIsPublic(bool value) {
    _isPublic = value;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setOwner(String value) {
    _owner = value;
    notifyListeners();
  }

  void setFollowers(List<String> value) {
    _followers = value;
    notifyListeners();
  }

  void setCurrentFollowerInput(String value) {
    _currentFollowerInput = value;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setTags(List<String> tags) {
    _selectedTags = tags;
    notifyListeners();
  }

  void setSources(List<String> sources) {
    _selectedSources = sources;
    notifyListeners();
  }

  bool addFollower(String value) {
    if (_followers.contains(value)) {
      return false;
    }
    _followers.add(value);
    notifyListeners();
    return true;
  }

  bool removeFollower(String value) {
    if (value == _currentUserEmail) {
      return false;
    }
    if (!_followers.contains(value)) {
      return false;
    }
    _followers.remove(value);
    notifyListeners();
    return true;
  }

  void reset() {
    _selectedSources.clear();
    _selectedTags.clear();
    _title = '';
    _description = '';
    _followers.clear();
    _owner = '';
    _sendToMail = false;
    _mobileNotifications = false;
    _isPublic = false;
    _currentFollowerInput = '';
    notifyListeners();
  }

  bool areFieldsEmpty() {
    return _title.isEmpty ||
        _selectedSources.isEmpty ||
        _description.isEmpty ||
        _followers.isEmpty ||
        _owner.isEmpty ||
        _selectedTags.isEmpty ||
        _currentFollowerInput.isEmpty ||
        !_sendToMail ||
        !_mobileNotifications ||
        !_isPublic;
  }

  void addDefault() {
    // TODO добавление пользоваателя
    addFollower("default");
    notifyListeners();
  }

  void resetAndAddDefault() {
    reset();
    addDefault();
    notifyListeners();
  }

  void addSubscription() {
    // TODO добавление подписки
    Subscription subscription = Subscription(
      id: _subscriptions.length + 1,
      title: _title,
      description: _description,
      sources: _selectedSources,
      tags: _selectedTags,
      subscribeOptions: SubscribeOptions(
        subscribed: true,
        sendToMail: _sendToMail,
        mobileNotifications: _mobileNotifications,
      ),
      creationDate: DateTime.now().toString(),
      public: _isPublic,
      owner: "default",
      isOwner: true,
      followers: _followers,
    );
    _subscriptions.add(subscription);
    notifyListeners();
  }

  void updateSubscription(Subscription updatedSubscription) {
    final index =
        _subscriptions.indexWhere((sub) => sub.id == updatedSubscription.id);
    if (index != -1) {
      // TODO связь с бэком
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
    }
  }

  void transferOwnership(Subscription subscription, String newOwner) {
    int index = _subscriptions.indexWhere((sub) => sub.id == subscription.id);

    // TODO перенос владельца
    if (index != -1) {
      _subscriptions[index] =
          subscription.copyWith(owner: newOwner, isOwner: false);
      notifyListeners();
    }
  }

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newSubscriptions = await ApiService.fetchAvailableSubscriptions();
      _subscriptions
        ..clear()
        ..addAll(newSubscriptions);
    } catch (e) {
      debugPrint("Ошибка при загрузке подписок: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void toggleSource(String source) {
    if (_selectedSources.contains(source)) {
      _selectedSources.remove(source);
    } else {
      _selectedSources.add(source);
    }
  }

  @override
  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
  }

  Future<void> createSubscription() async {
    if (_title.trim().isEmpty ||
        _description.trim().isEmpty ||
        _selectedSources.isEmpty ||
        _selectedTags.isEmpty ||
        _followers.isEmpty) {
      throw ('Заполните все обязательные поля');
    }

    _isCreating = true;
    notifyListeners();

    try {
      await ApiService.createSubscription(
        title: _title,
        description: _description,
        sources: _selectedSources,
        tags: _selectedTags,
        followers: _followers,
        subscribeOptions: SubscribeOptions(
          sendToMail: _sendToMail,
          mobileNotifications: _mobileNotifications,
          subscribed: true,
        ),
        isPublic: _isPublic,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ('Некорректные источники');
      } else if (e.response?.statusCode == 401) {
        throw ('Вы не авторизованы');
      } else if (e.response?.statusCode == 404) {
        throw ('Не найден один или несколько подписчиков');
      } else {
        throw ('Неизвестная ошибка: ${e.message}');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> fetchCurrentUserEmail() async {
    try {
      _currentUserEmail = await ApiService.getCurrentUserEmail();
      if (!_followers.contains(_currentUserEmail)) {
        _followers.insert(0, _currentUserEmail);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка получения email пользователя: $e');
    }
  }

  Future<void> addFollowerWithValidation(String email) async {
    try {
      final data = await ApiService.getUserSubscriptionSettings(email);

      if (data['subscribable'] != true) {
        throw ('Пользователя нельзя добавить в рассылку');
      }

      if (_followers.contains(email)) {
        throw ('Этот пользователь уже добавлен');
      }

      _followers.add(email);
      notifyListeners();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ('Пользователь не найден');
      } else if (e.response?.statusCode == 403) {
        throw ('Пользователя нельзя добавить в рассылку');
      } else {
        throw ('Ошибка проверки пользователя: ${e.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  void clear() {
    _subscriptions.clear();
    _selectedSources.clear();
    _selectedTags.clear();
    _title = '';
    _description = '';
    _followers.clear();
    _owner = '';
    _sendToMail = false;
    _mobileNotifications = false;
    _isPublic = false;
    _currentFollowerInput = '';
    _isLoading = false;
    _selectedCategory = "Все дайджесты";
    _selectedSubscriptionId = null;
    notifyListeners();
  }
}
