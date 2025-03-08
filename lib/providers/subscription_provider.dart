import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/fake/fake_subscriptions.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];

  int? _selectedSubscriptionId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  int? get selectedSubscriptionId => _selectedSubscriptionId;
  List<Subscription> get subscriptions => _subscriptions;

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
}
