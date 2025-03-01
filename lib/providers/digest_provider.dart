import 'package:flutter/material.dart';
import '../data/models/digest.dart';
import '../data/fake/fake_digests.dart';

class DigestProvider extends ChangeNotifier {
  List<Digest> _digests = [];
  bool _isLoading = false;
  String _selectedCategory = 'Все дайджесты';

  List<Digest> get digests => _digests;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadDigests() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _digests = fakeDigests.toList();

    _isLoading = false;
    notifyListeners();
  }
}