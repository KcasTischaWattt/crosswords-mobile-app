import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../data/models/article.dart';
import '../screens/article_detail_page.dart';

class ArticlesPage extends StatefulWidget  {
  final bool isFavoriteDialogEnabled;

  const ArticlesPage({super.key, required this.isFavoriteDialogEnabled});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;

  // Поля ввода
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateFromController = TextEditingController();
  final TextEditingController _dateToController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late ScrollController _scrollController;

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
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<ArticleProvider>(context, listen: false).loadArticles();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearchVisibility() {
    Provider.of<ArticleProvider>(context, listen: false).toggleSearchVisibility();
    setState(() {
      _isSearchExpanded = false;
      _animationController.reset();
    });
  }

  void _onScroll() {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      provider.loadArticles();
    }
  }

  void _toggleSearchExpanded() {
    _isSearchExpanded = !_isSearchExpanded;
    _isSearchExpanded ? _animationController.forward() : _animationController.reverse();
  }

  void _setSearchOption(String option) {
    Provider.of<ArticleProvider>(context, listen: false).setSearchOption(option);
    _toggleSearchExpanded();
  }

  Future<void> _toggleFavorite(String articleId) async {
    await Provider.of<ArticleProvider>(context, listen: false).toggleFavorite(articleId);
  }

  void _resetFilters() {
    Provider.of<ArticleProvider>(context, listen: false).resetFilters();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildSearchInterface() {
    final provider = Provider.of<ArticleProvider>(context);
    return Visibility(
      visible: provider.isSearchVisible,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Строка поиска
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Поле ввода
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'Строка поиска',
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      ),
                    ),
                  ),
                  // Иконка лупы
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Чекбокс
            if (provider.selectedSearchOption == 'Точный поиск') ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Искать в тексте',
                  style: TextStyle(fontSize: 20),
                ),
                value: provider.searchInText,
                onChanged: (bool? value) {
                  setState(() {
                    provider.setSearchInText(value ?? false);
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],

            // Фильтры и даты
            if (provider.selectedSearchOption != 'Поиск по ID') ...[
              const SizedBox(height: 16),

              // Аккордеон Источники
              ExpansionTile(
                title: const Text('Источники', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                children: provider.sources.map((source) {
                  return CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(source, style: const TextStyle(fontSize: 20)),
                    value: provider.selectedSources.contains(source),
                    onChanged: (bool? value) {
                      setState(() {
                        provider.toggleSource(source);
                      });
                    },
                  );
                }).toList(),
              ),

              // Аккордеон Тэги
              ExpansionTile(
                title: const Text('Тэги', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                children: provider.tags.map((tag) {
                  return CheckboxListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(tag, style: const TextStyle(fontSize: 20)),
                    value: provider.selectedTags.contains(tag),
                    onChanged: (bool? value) {
                      setState(() {
                        provider.toggleTag(tag);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Поля выбора даты
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _dateFromController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 20),
                        onTap: () => _selectDate(context, _dateFromController),
                        decoration: const InputDecoration(
                          labelText: 'Дата С',
                          labelStyle: TextStyle(fontSize: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _dateToController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 20),
                        onTap: () => _selectDate(context, _dateToController),
                        decoration: const InputDecoration(
                          labelText: 'Дата По',
                          labelStyle: TextStyle(fontSize: 20),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Кнопки "Найти" и "Сбросить фильтры"
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      print('Ищем: ${_searchController.text}');
                      print('Источники: ${provider.selectedSources.toList()}');
                      print('Тэги: ${provider.selectedTags.toList()}');
                      print('Дата с: ${_dateFromController.text}');
                      print('Дата по: ${_dateToController.text}');
                      print('Искать в тексте: $provider.searchInText');
                    },
                    child: const Text('Найти', style: TextStyle(fontSize: 22, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Сбросить фильтры', style: TextStyle(fontSize: 20)),
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
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        final List<Article> allArticles = provider.articles;
        final List<Article> displayedArticles = provider.showOnlyFavorites
            ? allArticles.where((article) => provider.favoriteArticles.contains(article.id)).toList()
            : allArticles;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            title: Row(
              children: [
                const Text(
                  'Статьи',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: provider.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(
                    provider.showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                    color: provider.showOnlyFavorites ? Colors.red : Colors.grey,
                    size: 30,
                  ),
                  onPressed: provider.isLoading ? null : provider.toggleShowFavorites,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 30),
                onPressed: _toggleSearchVisibility,
              ),
            ],
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // Аккордеон с выбором типа поиска
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
                                  provider.selectedSearchOption,
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
                              padding: const EdgeInsets.only(bottom: 0),
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
                                    contentPadding: const EdgeInsets.only(top: 8, bottom: 0),
                                    title: const Text('Поиск по ID'),
                                    onTap: () => _setSearchOption('Поиск по ID'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                crossFadeState: provider.isSearchVisible
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              // Интерфейс поиска
              _buildSearchInterface(),

              // Список статей
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: displayedArticles.length + (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayedArticles.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final Article article = displayedArticles[index];
                    final isFavorite = provider.favoriteArticles.contains(article.id);

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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ArticleDetailPage(
                                            article: article,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Подробнее', style: TextStyle(color: Colors.black, fontSize: 22)),
                                  )
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 30,
                              ),
                              onPressed: () async => await _toggleFavorite(article.id),
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
      },
    );
  }
}