import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/fake/fake_subscriptions.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Subscription> get subscriptions => _subscriptions;

  void updateSubscription(Subscription updatedSubscription) {
    final index =
        _subscriptions.indexWhere((sub) => sub.id == updatedSubscription.id);
    if (index != -1) {
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
    }
  }

  void transferOwnership(Subscription subscription, String newOwner) {
    int index = _subscriptions.indexWhere((sub) => sub.id == subscription.id);

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
