import 'package:crosswords/data/constants/filter_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/digest.dart';
import '../services/api_service.dart';
import 'abstract/filter_provider.dart';
import '../data/models/search_params/digest_search_params.dart';

class DigestProvider extends ChangeNotifier implements FilterProvider {
  final List<Digest> _digests = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
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
  List<String> get sources => defaultSources;

  @override
  List<String> get tags => defaultTags;

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
      return _digests
          .where((digest) => digest.subscribeOptions.subscribed)
          .toList();
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

  Future<void> _fetchDigests({bool isLoadMore = false}) async {
    if (_isLoading || (isLoadMore && _isLoadingMore)) return;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      if (!isLoadMore) {
        _currentPage = 0;
      }
    }

    notifyListeners();

    try {
      final newDigests = await ApiService.fetchDigests(
        pageNumber: _currentPage,
        matchesPerPage: _pageSize,
      );

      if (!isLoadMore) {
        _digests.clear();
      }

      if (newDigests.isNotEmpty) {
        _digests.addAll(newDigests);
        _currentPage++;
      }
    } catch (e) {
      debugPrint("Ошибка при загрузке дайджестов: $e");
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _searchDigests({bool isLoadMore = false}) async {
    if (_isLoading || (isLoadMore && _isLoadingMore)) return;

    if (isLoadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      if (!isLoadMore) {
        _currentPage = 0;
      }
    }

    notifyListeners();

    try {
      final newDigests = await ApiService.searchDigests(
        searchParams: _currentSearchParams,
        pageNumber: _currentPage,
        matchesPerPage: _pageSize,
      );

      if (!isLoadMore) {
        _digests.clear();
      }

      if (newDigests.isNotEmpty) {
        _digests.addAll(newDigests);
        _currentPage++;
      }
    } catch (e) {
      debugPrint("Ошибка при поиске дайджестов: $e");
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  void setDateFromDateTime(DateTime date) {
    final formatted = DateFormat('dd/MM/yyyy').format(date);
    _tempSearchParams = _tempSearchParams.copyWith(dateFrom: formatted);
    notifyListeners();
  }

  void setDateToDateTime(DateTime date) {
    final formatted = DateFormat('dd/MM/yyyy').format(date);
    _tempSearchParams = _tempSearchParams.copyWith(dateTo: formatted);
    notifyListeners();
  }

  Future<void> loadDigests() async => _fetchDigests();

  Future<void> loadMoreDigests() async => _fetchDigests(isLoadMore: true);

  Future<void> loadSearchedDigests() async => _searchDigests();

  Future<void> loadMoreSearchedDigests() async =>
      _searchDigests(isLoadMore: true);

  void clear() {
    _digests.clear();
    _isLoading = false;
    _isLoadingMore = false;
    _currentPage = 0;
    _selectedCategory = 'Все дайджесты';
    _currentSearchParams = DigestSearchParams(
      searchQuery: '',
      dateFrom: '',
      dateTo: '',
      selectedSources: [],
      selectedTags: [],
    );
    _tempSearchParams = DigestSearchParams(
      searchQuery: '',
      dateFrom: '',
      dateTo: '',
      selectedSources: [],
      selectedTags: [],
    );
    notifyListeners();
  }
}
