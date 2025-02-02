import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Для выбора дат
import '../data/fake_articles.dart';
import '../models/article.dart';

class ArticlesPage extends StatefulWidget {
  final bool isFavoriteDialogEnabled;

  const ArticlesPage({Key? key, required this.isFavoriteDialogEnabled}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> with SingleTickerProviderStateMixin {
  final Set<int> _favoriteArticles = {};
  bool _isSearchVisible = false;
  bool _isSearchExpanded = false;
  bool _showOnlyFavorites = false;
  String _selectedSearchOption = 'Поиск по смыслу';

  // Поля ввода
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();
  bool _searchInText = false; // Только для точного поиска

  // Списки источников и тэгов
  final List<String> _sources = ['Источник 1', 'Источник 2', 'Источник 3'];
  final List<String> _tags = ['Тэг 1', 'Тэг 2', 'Тэг 3'];

  // Выбранные фильтры
  final Set<String> _selectedSources = {};
  final Set<String> _selectedTags = {};

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  void _toggleSearchVisibility() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      _isSearchExpanded = false;
      _animationController.reset();
    });
  }

  void _toggleSearchExpanded() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _setSearchOption(String option) {
    setState(() {
      _selectedSearchOption = option;
      _toggleSearchExpanded();  // Сворачиваем аккордеон после выбора
    });
  }

  void _toggleFavorite(int articleId) {
    setState(() {
      if (_favoriteArticles.contains(articleId)) {
        _favoriteArticles.remove(articleId);
      } else {
        _favoriteArticles.add(articleId);
      }
    });
  }

  void _toggleShowFavorites() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _dateFromController.clear();
      _dateToController.clear();
      _selectedSources.clear();
      _selectedTags.clear();
      _searchInText = false;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _buildSearchInterface() {
    return Visibility(
      visible: _isSearchVisible,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Строка поиска',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedSearchOption != 'Поиск по ID') ...[
              ExpansionTile(
                title: const Text('Источники'),
                children: _sources.map((source) {
                  return CheckboxListTile(
                    title: Text(source),
                    value: _selectedSources.contains(source),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedSources.add(source);
                        } else {
                          _selectedSources.remove(source);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              ExpansionTile(
                title: const Text('Тэги'),
                children: _tags.map((tag) {
                  return CheckboxListTile(
                    title: Text(tag),
                    value: _selectedTags.contains(tag),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateFromController,
                      decoration: const InputDecoration(
                        labelText: 'Дата С',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateFromController),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _dateToController,
                      decoration: const InputDecoration(
                        labelText: 'Дата По',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateToController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedSearchOption == 'Точный поиск')
                CheckboxListTile(
                  title: const Text('Искать в тексте'),
                  value: _searchInText,
                  onChanged: (bool? value) {
                    setState(() {
                      _searchInText = value ?? false;
                    });
                  },
                ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Отправка данных на бэкенд будет здесь
                    print('Ищем: ${_searchController.text}');
                    print('Источники: ${_selectedSources.toList()}');
                    print('Тэги: ${_selectedTags.toList()}');
                    print('Дата с: ${_dateFromController.text}');
                    print('Дата по: ${_dateToController.text}');
                    print('Искать в тексте: $_searchInText');
                  },
                  child: const Text('Найти'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Сбросить фильтры'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Article> displayedArticles = _showOnlyFavorites
        ? fakeArticles.where((article) {
      final int articleId = int.tryParse(article.id) ?? article.id.hashCode;
      return _favoriteArticles.contains(articleId);
    }).toList()
        : fakeArticles;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,  // Увеличиваем высоту AppBar
        title: Row(
          children: [
            const Text(
              'Статьи',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                color: _showOnlyFavorites ? Colors.red : Colors.grey,
                size: 30,
              ),
              onPressed: _toggleShowFavorites,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 30),  // Увеличиваем размер иконки поиска
            onPressed: _toggleSearchVisibility,
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: _toggleSearchExpanded,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _toggleSearchExpanded,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedSearchOption,
                              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              _isSearchExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: _isSearchExpanded,
                        child: const SizedBox(height: 8),
                      ),
                      SizeTransition(
                        sizeFactor: _expandAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),  // Убираем отступ снизу
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                title: const Text('Поиск по смыслу'),
                                onTap: () => _setSearchOption('Поиск по смыслу'),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                title: const Text('Точный поиск'),
                                onTap: () => _setSearchOption('Точный поиск'),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.only(top: 8, bottom: 0),  // Уменьшаем нижний отступ
                                title: const Text('Поиск по ID'),
                                onTap: () => _setSearchOption('Поиск по ID'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
            crossFadeState: _isSearchVisible
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedArticles.length,
              itemBuilder: (context, index) {
                final Article article = displayedArticles[index];
                final int articleId = int.tryParse(article.id) ?? article.id.hashCode;
                final isFavorite = _favoriteArticles.contains(articleId);

                return Card(
                  color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'Источник: ${article.source}',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                                  ),
                                  const SizedBox(width: 15),
                                  Baseline(
                                    baseline: 14,
                                    baselineType: TextBaseline.alphabetic,
                                    child: Text(
                                      article.date,
                                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                article.summary,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Открыта статья: ${article.title}')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Подробнее', style: TextStyle(color: Colors.black, fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 30,
                          ),
                          onPressed: () => _toggleFavorite(articleId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
