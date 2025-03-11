import 'package:crosswords/providers/abstract/filter_provider.dart';
import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/fake/fake_subscriptions.dart';
import '../data/models/subscribe_options.dart';

class SubscriptionProvider extends ChangeNotifier implements FilterProvider {
  List<Subscription> _subscriptions = [];
  List<String> _sources = [
    'Источник 1',
    'Источник 2',
    'Источник 3',
    'Источник 4',
    'Источник 5',
    'Источник 6'
  ];
  List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3', 'Тэг 4', 'Тэг 5', 'Тэг 6'];

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

  bool get isLoading => _isLoading;

  int? get selectedSubscriptionId => _selectedSubscriptionId;

  List<Subscription> get subscriptions => _subscriptions;

  @override
  List<String> get selectedSources => _selectedSources;

  @override
  List<String> get selectedTags => _selectedTags;

  @override
  List<String> get sources => _sources;

  @override
  List<String> get tags => _tags;

  bool get sendToMail => _sendToMail;

  bool get mobileNotifications => _mobileNotifications;

  bool get isPublic => _isPublic;

  String get title => _title;

  String get description => _description;

  String get owner => _owner;

  List<String> get followers => _followers;

  String get currentFollowerInput => _currentFollowerInput;

  String get selectedCategory => _selectedCategory;

  List<Subscription> get filteredSubscriptions {
    if (_selectedCategory == "Все дайджесты") {
      return _subscriptions;
    } else if (_selectedCategory == "Подписки") {
      return _subscriptions.where((sub) => sub.subscribeOptions.subscribed).toList();
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

  bool addFollower(String value) {
    if (_followers.contains(value)) {
      return false;
    }
    _followers.add(value);
    notifyListeners();
    return true;
  }

  bool removeFollower(String value) {
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

    // TODO загрузка дайджестов
    await Future.delayed(const Duration(seconds: 1));

    List<Subscription> newDigests = fakeSubscriptions.toList();

    _subscriptions.clear();
    _subscriptions.addAll(newDigests);

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
}
