import 'package:flutter/material.dart';
import '../data/models/article.dart';
import '../data/models/note.dart';
import '../data/fake/fake_articles.dart';
import 'abstract/filter_provider.dart';
import '../data/models/search_params/article_search_params.dart';

class ArticleProvider extends ChangeNotifier implements FilterProvider {
  List<Article> _articles = [];
  List<String> _sources = ['Источник 1', 'Источник 2', 'Источник 3', 'Источник 4', 'Источник 5', 'Источник 6'];
  List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3', 'Тэг 4', 'Тэг 5', 'Тэг 6'];

  final Set<String> _favoriteArticles = {}; // TODO убрать список ID избранных статей после подключения бэкэнда
  final List<Note> _notes = [];
  bool _isLoading = false;
  bool _showOnlyFavorites = false;
  bool _isSearchVisible = false;
  bool _isLoadingMore = false;
  // TODO не забыть использовать для запроса к API
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

  // Поля поиска
  String _selectedSearchOption = 'Поиск по смыслу';
  String _searchQuery = '';
  String _dateFrom = '';
  String _dateTo = '';
  List<String> _selectedSources = [];
  List<String> _selectedTags = [];
  bool _searchInText = false;

  @override
  List<String> get sources => _sources;
  @override
  List<String> get tags => _tags;
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  Set<String> get favoriteArticles => _favoriteArticles;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get selectedSearchOption => _selectedSearchOption;
  @override
  List<String> get selectedSources => _selectedSources;
  @override
  List<String> get selectedTags => _selectedTags;
  bool get searchInText => _searchInText;
  bool get isSearchVisible => _isSearchVisible;
  bool get isLoadingMore => _isLoadingMore;
  List<Note> get notes => _notes;
  String get searchQuery => _searchQuery;
  String get dateFrom => _dateFrom;
  String get dateTo => _dateTo;

  // TODO переделать систему получения заметок
  List<Note> getNotesForArticle(int articleId) {
    return _notes.where((note) => note.articleId == articleId).toList();
  }

  Future<void> loadArticles() async {
    _currentPage = 1;
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки

    // TODO загрузка данных
    List<Article> newArticles = fakeArticles.toList();

    _articles.replaceRange(0, _articles.length, newArticles);
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateFrom(String date) {
    _dateFrom = date;
    notifyListeners();
  }

  void setDateTo(String date) {
    _dateTo = date;
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

  void setSearchInText(bool value) {
    _searchInText = value;
    notifyListeners();
  }

  void resetFilters() {
    _selectedSources.clear();
    _selectedTags.clear();
    _searchInText = false;
    _searchQuery = '';
    _dateFrom = '';
    _dateTo = '';
    notifyListeners();
  }

  void toggleSearchVisibility() {
    _isSearchVisible = !_isSearchVisible;
    notifyListeners();
  }

  // TODO заагрузка заметок
  Future<void> loadNotes(int articleId) async {
    _isLoading = true;
    notifyListeners();

    _isLoading = false;
    notifyListeners();
  }

  // Метод для добавления заметки
  Future<void> addNote(int articleId, String text) async {
    if (text.trim().isEmpty) return;

    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch, // Временный ID
      text: text,
      user: "User1", // TODO Заглушка, потом заменить на userId
      articleId: articleId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    _notes.add(newNote);
    notifyListeners();

    // TODO Отправить данные на сервер
  }

  void updateNote(int noteId, String newText) {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index == -1) return;
    _notes[index] = _notes[index].copyWith(text: newText, updatedAt: DateTime.now().toIso8601String());
    notifyListeners();
  }

  // Метод для удаления заметки
  Future<void> deleteNote(int noteId) async {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();

    // TODO Отправить запрос на удаление заметки на сервер
    // await ApiService.deleteNote(noteId);
  }
}
