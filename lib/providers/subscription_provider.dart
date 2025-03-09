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

  void setSelectedSubscription(int? subscriptionId) {
    _selectedSubscriptionId = subscriptionId;
    notifyListeners();
  }

  void resetSelectedSubscription() {
    _selectedSubscriptionId = null;
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
