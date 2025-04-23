import 'package:crosswords/data/constants/filter_constants.dart';
import 'package:flutter/material.dart';
import '../data/models/article.dart';
import '../data/models/note.dart';
import '../services/api_service.dart';
import 'abstract/filter_provider.dart';
import '../data/models/search_params/article_search_params.dart';

class ArticleProvider extends ChangeNotifier implements FilterProvider {
  final List<Article> _articles = [];
  final List<String> _sources = List<String>.from(defaultSources);
  final List<String> _tags = List<String>.from(defaultTags);

  final Set<int> _favoriteArticles =
      {}; // TODO убрать список ID избранных статей после подключения бэкэнда
  final List<Note> _notes = [];
  bool _isLoading = false;
  bool _showOnlyFavorites = false;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  final int _pageSize = 10;

  ArticleSearchParams _currentSearchParams = ArticleSearchParams(
    searchQuery: '',
    dateFrom: '',
    dateTo: '',
    selectedSources: [],
    selectedTags: [],
    searchInText: false,
    searchOption: 'Поиск по смыслу',
  );

  ArticleSearchParams _tempSearchParams = ArticleSearchParams(
    searchQuery: '',
    dateFrom: '',
    dateTo: '',
    selectedSources: [],
    selectedTags: [],
    searchInText: false,
    searchOption: 'Поиск по смыслу',
  );

  @override
  List<String> get sources => defaultSources;

  @override
  List<String> get tags => defaultTags;

  List<Article> get articles => _articles;

  bool get isLoading => _isLoading;

  Set<int> get favoriteArticles => _favoriteArticles;

  bool get showOnlyFavorites => _showOnlyFavorites;

  bool get isLoadingMore => _isLoadingMore;

  List<Note> get notes => _notes;

  String get selectedSearchOption => _tempSearchParams.searchOption;

  bool get searchInText => _tempSearchParams.searchInText;

  String get searchQuery => _tempSearchParams.searchQuery;

  String get dateFrom => _tempSearchParams.dateFrom;

  String get dateTo => _tempSearchParams.dateTo;

  @override
  List<String> get selectedSources => _tempSearchParams.selectedSources;

  @override
  List<String> get selectedTags => _tempSearchParams.selectedTags;

  // TODO переделать систему получения заметок
  List<Note> getNotesForArticle(int articleId) {
    return _notes.where((note) => note.articleId == articleId).toList();
  }

  Future<void> loadArticles() async {
    _currentPage = 1;
    _isLoading = true;
    notifyListeners();

    try {
      final searchParams = _currentSearchParams.toApiJson(
          _currentPage, _pageSize, _showOnlyFavorites);
      List<Article> newArticles =
          await ApiService.fetchDocuments(searchParams: searchParams);
      _articles
        ..clear()
        ..addAll(newArticles);
      _currentPage++;
    } catch (e) {
      debugPrint("Ошибка при загрузке статей: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreArticles() async {
    if (_isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final searchParams = _currentSearchParams.toApiJson(
          _currentPage, _pageSize, _showOnlyFavorites);
      List<Article> newArticles =
          await ApiService.fetchDocuments(searchParams: searchParams);
      _articles.addAll(newArticles);
      _currentPage++;
    } catch (e) {
      debugPrint("Ошибка при загрузке статей: $e");
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    // TODO запрос к API
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  Future<void> toggleFavorite(int articleId) async {
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

  bool isFavorite(int articleId) {
    return _favoriteArticles.contains(articleId);
  }

  void toggleShowFavorites() {
    _showOnlyFavorites = !_showOnlyFavorites;
    notifyListeners();
  }

  void setSearchOption(String option) {
    _tempSearchParams = _tempSearchParams.copyWith(searchOption: option);
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

  void setSearchInText(bool value) {
    _tempSearchParams = _tempSearchParams.copyWith(searchInText: value);
    notifyListeners();
  }

  void resetFilters() {
    _tempSearchParams = _tempSearchParams.resetFilters();
    _currentSearchParams = _currentSearchParams.resetFilters();
    notifyListeners();
  }

  void applySearchParams() {
    _currentSearchParams = _tempSearchParams.copyWith(
      searchQuery: _tempSearchParams.searchQuery,
      dateFrom: _tempSearchParams.dateFrom,
      dateTo: _tempSearchParams.dateTo,
      selectedSources: List<String>.from(_tempSearchParams.selectedSources),
      selectedTags: List<String>.from(_tempSearchParams.selectedTags),
      searchInText: _tempSearchParams.searchInText,
      searchOption: _tempSearchParams.searchOption,
    );
    notifyListeners();
  }

  // TODO заагрузка заметок
  Future<void> loadNotes(int articleId) async {
    _isLoading = true;
    notifyListeners();

    _isLoading = false;
    notifyListeners();
  }

  /// Метод для добавления заметки
  Future<void> addNote(int articleId, String text) async {
    if (text.trim().isEmpty) return;

    // TODO Отправить данные на сервер
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch,
      text: text,
      user: "User1",
      articleId: articleId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    _notes.add(newNote);
    notifyListeners();
  }

  void updateNote(int noteId, String newText) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    _notes[index] = _notes[index]
        .copyWith(text: newText, updatedAt: DateTime.now().toIso8601String());
    notifyListeners();
  }

  /// Метод для удаления заметки
  Future<void> deleteNote(int noteId) async {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();

    // TODO Отправить запрос на удаление заметки на сервер
    // await ApiService.deleteNote(noteId);
  }

  void clear() {
    _articles.clear();
    _favoriteArticles.clear();
    _notes.clear();
    _isLoading = false;
    _showOnlyFavorites = false;
    _isLoadingMore = false;
    _currentPage = 1;
    _currentSearchParams = ArticleSearchParams(
      searchQuery: '',
      dateFrom: '',
      dateTo: '',
      selectedSources: [],
      selectedTags: [],
      searchInText: false,
      searchOption: 'Поиск по смыслу',
    );
    _tempSearchParams = ArticleSearchParams(
      searchQuery: '',
      dateFrom: '',
      dateTo: '',
      selectedSources: [],
      selectedTags: [],
      searchInText: false,
      searchOption: 'Поиск по смыслу',
    );
    notifyListeners();
  }
}
