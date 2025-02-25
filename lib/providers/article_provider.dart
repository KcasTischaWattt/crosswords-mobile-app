import 'package:flutter/material.dart';
import '../data/models/article.dart';
import '../data/fake/fake_articles.dart';

class ArticleProvider extends ChangeNotifier {
  List<Article> _articles = [];
  List<String> _sources = ['Источник 1', 'Источник 2', 'Источник 3'];
  List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3'];

  List<String> get sources => _sources;
  List<String> get tags => _tags;
  bool _isLoading = false;
  Set<String> _favoriteArticles = {}; // TODO убрать список ID избранных статей после подключения бэкэнда
  bool _showOnlyFavorites = false;
  String _selectedSearchOption = 'Поиск по смыслу';
  Set<String> _selectedSources = {};
  Set<String> _selectedTags = {};
  bool _searchInText = false;
  bool _isSearchVisible = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 10;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  Set<String> get favoriteArticles => _favoriteArticles;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get selectedSearchOption => _selectedSearchOption;
  Set<String> get selectedSources => _selectedSources;
  Set<String> get selectedTags => _selectedTags;
  bool get searchInText => _searchInText;
  bool get isSearchVisible => _isSearchVisible;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadArticles() async {
    _currentPage = 1;
    _articles.clear();
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки

    // TODO загрузка данных
    List<Article> newArticles = fakeArticles.toList();

    _articles = newArticles;
    _currentPage++;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки

    // TODO загрузка данных
    List<Article> newArticles = fakeArticles.toList();

    _articles.addAll(newArticles);
    _currentPage++;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    // TODO запрос к API
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  Future<void> toggleFavorite(String articleId) async {
    _isLoading = true;
    notifyListeners();

    // TODO запрос на сервер
    await Future.delayed(const Duration(seconds: 1));
    if (!_favoriteArticles.contains(articleId)) {
      _favoriteArticles.add(articleId);
    } else {
      _favoriteArticles.remove(articleId);
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(String articleId) {
    return _favoriteArticles.contains(articleId);
  }

  void toggleShowFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  void setSearchOption(String option) {
    _selectedSearchOption = option;
    notifyListeners();
  }

  void toggleSource(String source) {
    if (_selectedSources.contains(source)) {
      _selectedSources.remove(source);
    } else {
      _selectedSources.add(source);
    }
    notifyListeners();
  }

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void setSearchInText(bool value) {
    _searchInText = value;
    notifyListeners();
  }

  void resetFilters() {
    _selectedSources.clear();
    _selectedTags.clear();
    _searchInText = false;
    notifyListeners();
  }

  void toggleSearchVisibility() {
    _isSearchVisible = !_isSearchVisible;
    notifyListeners();
  }
}
