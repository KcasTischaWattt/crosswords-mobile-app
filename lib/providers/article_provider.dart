import 'package:flutter/material.dart';
import '../data/models/article.dart';

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

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  Set<String> get favoriteArticles => _favoriteArticles;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get selectedSearchOption => _selectedSearchOption;
  Set<String> get selectedSources => _selectedSources;
  Set<String> get selectedTags => _selectedTags;
  bool get searchInText => _searchInText;
  bool get isSearchVisible => _isSearchVisible;


  // TODO загрузка данных
  Future<void> loadArticles() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Имитация задержки

    _articles = [
      Article(
        id: "1",
        title: "Оборот разработчиков ПО в ноябре вырос на 28,9% г/г - Росстат",
        source: "Интерфакс",
        summary: "Оборот организаций, занимающихся разработкой ПО, консультационными и другими услугами в этой сфере, в ноябре 2024 года увеличился на 28,9% по сравнению с ноябрем 2023 года",
        text: "Оборот организаций, занимающихся разработкой программного обеспечения (ПО), консультационными и другими сопутствующими услугами в этой сфере, в ноябре 2024 года увеличился на 28,9% по сравнению с ноябрем 2023 года",
        tags: ["IT", "Экономика", "Зарплаты"],
        date: "25/03/2024",
        favorite: false,
        language: "RU",
        url: "https://www.interfax.ru/business/1001194",
      ),
      Article(
        id: "2",
        title: "Рынок технологий искусственного интеллекта достиг рекордных масштабов",
        source: "РБК",
        summary: "Искусственный интеллект продолжает активно развиваться в различных сферах бизнеса.",
        text: "Рынок технологий ИИ достиг рекордных масштабов благодаря внедрению в медицину, финансы и производство.",
        tags: ["AI", "Технологии", "Бизнес"],
        date: "20/02/2024",
        favorite: false,
        language: "RU",
        url: "https://www.rbc.ru/tech/ai/2024",
      ),
      Article(
        id: "3",
        title: "Российские банки внедряют биометрические системы идентификации клиентов",
        source: "ТАСС",
        summary: "Крупнейшие банки России начали массово внедрять системы биометрической идентификации клиентов, что повысит безопасность финансовых операций.",
        text: "Банки в России активно внедряют технологии биометрической идентификации, что позволяет клиентам проходить аутентификацию с помощью отпечатков пальцев или распознавания лица.",
        tags: ["Банки", "Технологии", "Безопасность"],
        date: "10/01/2024",
        favorite: false,
        language: "RU",
        url: "https://tass.ru/finansy/biometria",
      ),

      Article(
        id: "4",
        title: "Криптовалюты продолжают падение на фоне мировых экономических опасений",
        source: "Ведомости",
        summary: "Курс биткойна и других основных криптовалют снизился на фоне растущей нестабильности на мировых финансовых рынках.",
        text: "Криптовалютный рынок переживает снижение цен, связанное с опасениями инвесторов из-за возможной рецессии в крупных экономиках мира.",
        tags: ["Криптовалюты", "Финансы", "Рынки"],
        date: "15/01/2024",
        favorite: false,
        language: "RU",
        url: "https://www.vedomosti.ru/finance/crypto-fall",
      ),

      Article(
        id: "5",
        title: "Россия планирует увеличить экспорт продукции IT-сектора в страны Азии",
        source: "Интерфакс",
        summary: "Российские компании IT-сектора намерены нарастить экспортные поставки программного обеспечения и технологий в азиатские страны.",
        text: "В условиях меняющегося внешнеэкономического климата российские IT-компании ищут новые рынки сбыта в странах Азии, чтобы компенсировать ограничения на Западе.",
        tags: ["Экспорт", "IT", "Азия"],
        date: "05/02/2024",
        favorite: false,
        language: "RU",
        url: "https://www.interfax.ru/business/it-export-asia",
      ),
    ];

    _isLoading = false;
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
