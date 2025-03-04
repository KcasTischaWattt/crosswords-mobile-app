import 'package:flutter/material.dart';
import '../data/models/digest.dart';
import '../data/fake/fake_digests.dart';
import 'abstract/filter_provider.dart';

class DigestProvider extends ChangeNotifier implements FilterProvider {
  List<Digest> _digests = [];
  List<String> _sources = ['Источник 1', 'Источник 2', 'Источник 3', 'Источник 4', 'Источник 5', 'Источник 6'];
  List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3', 'Тэг 4', 'Тэг 5', 'Тэг 6'];

  bool _isLoading = false;
  String _selectedCategory = 'Все дайджесты';

  // Поля поиска
  String _searchQuery = '';
  String _dateFrom = '';
  String _dateTo = '';
  List<String> _selectedSources = [];
  List<String> _selectedTags = [];

  List<Digest> get digests => _digests;
  @override
  List<String> get sources => _sources;
  @override
  List<String> get tags => _tags;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get dateFrom => _dateFrom;
  String get dateTo => _dateTo;
  @override
  List<String> get selectedSources => _selectedSources;
  @override
  List<String> get selectedTags => _selectedTags;

  void resetFilters() {
    _searchQuery = '';
    _dateFrom = '';
    _dateTo = '';
    _selectedSources.clear();
    _selectedSources.clear();
    notifyListeners();
  }

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

  @override
  void toggleSource(String source) {
    if (_selectedSources.contains(source)) {
      _selectedSources.remove(source);
    } else {
      _selectedSources.add(source);
    }
    notifyListeners();
  }

  @override
  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }
}
