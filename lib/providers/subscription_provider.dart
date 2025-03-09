import 'package:crosswords/providers/abstract/filter_provider.dart';
import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/fake/fake_subscriptions.dart';

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

  bool get isLoading => _isLoading;

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

  bool addFollower(String value) {
    if (!_followers.contains(value)) {
      _followers.add(value);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
  }

  bool removeFollower(String value) {
    if (_followers.contains(value)) {
      _followers.remove(value);
      notifyListeners();
      return true;
    } else {
      notifyListeners();
      return false;
    }
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
