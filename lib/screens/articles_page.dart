import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../data/models/article.dart';
import 'article_detail_page.dart';
import 'search_page.dart';

class ArticlesPage extends StatefulWidget {
  final bool isFavoriteDialogEnabled;

  const ArticlesPage({super.key, required this.isFavoriteDialogEnabled});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage>
    with SingleTickerProviderStateMixin {

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (provider.articles.isEmpty) {
        provider.loadArticles();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = Provider.of<ArticleProvider>(context, listen: false);
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore &&
        !provider.isLoading) {
      provider.loadMoreArticles();
    }
  }

  Future<void> _toggleFavorite(String articleId) async {
    await Provider.of<ArticleProvider>(context, listen: false)
        .toggleFavorite(articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, provider, child) {
        final List<Article> allArticles = provider.articles;
        final List<Article> displayedArticles = provider.showOnlyFavorites
            ? allArticles
                .where(
                    (article) => provider.favoriteArticles.contains(article.id))
                .toList()
            : allArticles;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 60,
            title: Row(
              children: [
                const Text(
                  'Статьи',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(
                          provider.showOnlyFavorites
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: provider.showOnlyFavorites
                              ? Colors.red
                              : Colors.grey,
                          size: 24,
                        ),
                  onPressed:
                      provider.isLoading ? null : provider.toggleShowFavorites,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 24),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  );
                },
              ),
            ],
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            controller: _scrollController,
            itemCount: displayedArticles.length +
                (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayedArticles.length) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final Article article = displayedArticles[index];
              final isFavorite =
              provider.favoriteArticles.contains(article.id);

              return Card(
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .backgroundColor,
                margin: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Источник: ${article.source}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .color),
                                ),
                                const SizedBox(width: 15),
                                Baseline(
                                  baseline: 12,
                                  baselineType:
                                  TextBaseline.alphabetic,
                                  child: Text(
                                    article.date,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ArticleDetailPage(
                                          article: article,
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Theme.of(context).primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8)),
                              ),
                              child: const Text('Подробнее',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18)),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                          isFavorite ? Colors.red : Colors.grey,
                          size: 24,
                        ),
                        onPressed: () async =>
                        await _toggleFavorite(article.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}