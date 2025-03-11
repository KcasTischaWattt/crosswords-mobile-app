import 'package:flutter/material.dart';
import '../data/models/digest.dart';
import '../data/fake/fake_digests.dart';
import 'abstract/filter_provider.dart';
import '../data/models/search_params/digest_search_params.dart';

class DigestProvider extends ChangeNotifier implements FilterProvider {
  List<Digest> _digests = [];
  List<String> _sources = [
    'Источник 1',
    'Источник 2',
    'Источник 3',
    'Источник 4',
    'Источник 5',
    'Источник 6'
  ];
  List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3', 'Тэг 4', 'Тэг 5', 'Тэг 6'];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 10;

  String _selectedCategory = 'Все дайджесты';

  DigestSearchParams _currentSearchParams = DigestSearchParams(
    searchQuery: '',
    dateFrom: '',
    dateTo: '',
    selectedSources: [],
    selectedTags: [],
  );

  DigestSearchParams _tempSearchParams = DigestSearchParams(
    searchQuery: '',
    dateFrom: '',
    dateTo: '',
    selectedSources: [],
    selectedTags: [],
  );

  List<Digest> get digests => _digests;

  @override
  List<String> get sources => _sources;

  @override
  List<String> get tags => _tags;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  String get selectedCategory => _selectedCategory;

  String get searchQuery => _tempSearchParams.searchQuery;

  String get dateFrom => _tempSearchParams.dateFrom;

  String get dateTo => _tempSearchParams.dateTo;

  DigestSearchParams get currentSearchParams => _currentSearchParams;

  DigestSearchParams get tempSearchParams => _tempSearchParams;

  @override
  List<String> get selectedSources => _tempSearchParams.selectedSources;

  @override
  List<String> get selectedTags => _tempSearchParams.selectedTags;

  List<Digest> get filteredDigests {
    if (_selectedCategory == "Все дайджесты") {
      return _digests;
    } else if (_selectedCategory == "Подписки") {
      return _digests.where((digest) => digest.subscribeOptions.subscribed).toList();
    } else if (_selectedCategory == "Приватные") {
      return _digests.where((digest) => !digest.public).toList();
    }
    return _digests;
  }

  void resetFilters() {
    _tempSearchParams = _tempSearchParams.resetFilters();
    _currentSearchParams = _currentSearchParams.resetFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _tempSearchParams = _tempSearchParams.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setDateFrom(String date) {
    _tempSearchParams = _tempSearchParams.copyWith(dateFrom: date);
    notifyListeners();
  }

  void setDateTo(String date) {
    _tempSearchParams = _tempSearchParams.copyWith(dateTo: date);
    notifyListeners();
  }

  void applySearchParams() {
    _currentSearchParams = _tempSearchParams.copyWith(
      searchQuery: _tempSearchParams.searchQuery,
      dateFrom: _tempSearchParams.dateFrom,
      dateTo: _tempSearchParams.dateTo,
      selectedSources: List<String>.from(_tempSearchParams.selectedSources),
      selectedTags: List<String>.from(_tempSearchParams.selectedTags),
    );
    notifyListeners();
  }

  void updateDigest(Digest updatedDigest) {
    final index =
        _digests.indexWhere((digest) => digest.id == updatedDigest.id);
    if (index != -1) {
      _digests[index] = updatedDigest;
      notifyListeners();
    }
  }

  Digest setRating(int rating, Digest digest) {
    return digest.copyWith(userRating: rating);
  }

  @override
  void toggleSource(String source) {
    final selectedSources =
        List<String>.from(_tempSearchParams.selectedSources);
    if (selectedSources.contains(source)) {
      selectedSources.remove(source);
    } else {
      selectedSources.add(source);
    }
    _tempSearchParams =
        _tempSearchParams.copyWith(selectedSources: selectedSources);
    notifyListeners();
  }

  @override
  void toggleTag(String tag) {
    final selectedTags = List<String>.from(_tempSearchParams.selectedTags);
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    _tempSearchParams = _tempSearchParams.copyWith(selectedTags: selectedTags);
    notifyListeners();
  }

  Future<void> loadDigests() async {
    _currentPage = 1;
    _isLoading = true;
    notifyListeners();

    // TODO загрузка дайджестов
    await Future.delayed(const Duration(seconds: 1));

    List<Digest> newDigests = fakeDigests.toList();

    _digests.clear();
    _digests.addAll(newDigests);
    _currentPage++;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreDigests() async {
    if (_isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // List<Digest> newDigests = fakeDigests.skip((_currentPage - 1) * _pageSize).take(_pageSize).toList();

    List<Digest> newDigests = fakeDigests.toList();

    if (newDigests.isNotEmpty) {
      _digests.addAll(newDigests);
      _currentPage++;
    }

    _isLoadingMore = false;
    notifyListeners();
  }
}
