import 'package:flutter/material.dart';
import '../data/models/subscription.dart';
import '../data/fake/fake_subscriptions.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<Subscription> _subscriptions = [];

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Subscription> get subscriptions => _subscriptions;

  Future<void> updateSubscription(Subscription subscription) async {

    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
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