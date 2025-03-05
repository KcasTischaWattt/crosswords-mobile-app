import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'all_digest_topics_page.dart';
import 'package:flutter/gestures.dart';
import 'digest_search_page.dart';

class DigestsPage extends StatefulWidget {
  const DigestsPage({super.key});

  @override
  _DigestsPageState createState() => _DigestsPageState();
}

class _DigestsPageState extends State<DigestsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      final provider = Provider.of<DigestProvider>(context, listen: false);
      if (provider.digests.isEmpty) {
        provider.loadDigests();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    _scrollController.dispose();
    super.dispose();
  }

  bool _shouldLoadMore(DigestProvider provider) {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !provider.isLoadingMore &&
        !provider.isLoading;
  }

  void _onScroll() {
    final provider = Provider.of<DigestProvider>(context, listen: false);
    if (_shouldLoadMore(provider)) {
      provider.loadMoreDigests();
    }
  }

  Widget _buildCategoryButtons(DigestProvider provider) {
    final categories = ["Все дайджесты", "Подписки", "Приватные"];

    return SizedBox(
      height: 50,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = provider.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(
                  category,
                  style: const TextStyle(fontSize: 14),
                ),
                selected: isSelected,
                onSelected: (_) => provider.setCategory(category),
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
    );
  }

  Widget _buildSubscriptionsRow() {
    return SizedBox(
      height: 80,
      child: Row(children: [
        // Карусель подписок
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person,
                            size: 25, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text("Дайджест $index",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Кнопка все
        Container(
          width: 60,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(),
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllDigestTopicsPage()),
              );
            },
            child: const Text(
              "Все",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
          ),
        ),
      ]),
    );
  }

  // диалоговое окно с источниками
  void _showAllSourcesDialog(BuildContext context, List<String> sources) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Все источники"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: sources
                  .map((source) => Text(
                        source,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }

  // диалоговое окно с тэгами
  void _showAllTagsDialog(BuildContext context, List<String> tags) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Все теги"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: tags
                  .map((tag) => Text(
                        tag,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }

  // Строки с источниками
  Widget _buildSourcesText(List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();

    final textColor = Theme.of(context).textTheme.bodyLarge!.color!;

    List<InlineSpan> spans = [
      const TextSpan(
        text: "Источники: ",
        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      ),
    ];

    if (sources.length <= 3) {
      for (int i = 0; i < sources.length; i++) {
        spans.add(TextSpan(
          text: sources[i],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        if (i < sources.length - 1) {
          spans.add(const TextSpan(
              text: ", ", style: TextStyle(fontWeight: FontWeight.normal)));
        }
      }
    } else {
      spans.add(TextSpan(
        text: sources[0],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      spans.add(const TextSpan(
          text: ", ", style: TextStyle(fontWeight: FontWeight.normal)));

      spans.add(TextSpan(
        text: sources[1],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      spans.add(const TextSpan(
          text: " и ", style: TextStyle(fontWeight: FontWeight.normal)));

      spans.add(TextSpan(
        text: "ещё ${sources.length - 2}",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: textColor),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _showAllSourcesDialog(context, sources);
          },
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
    );
  }

  // Тэги
  Widget _buildTags(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();

    double screenWidth = MediaQuery.of(context).size.width;
    int tagLimit = screenWidth <= 350 ? 2 : 3;
    int renderedTags = tags.length > tagLimit ? tagLimit - 1 : tags.length;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...tags.take(renderedTags).map((tag) => Chip(
              label: Text(tag,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).primaryColor,
            )),
        if (tags.length > tagLimit)
          GestureDetector(
            onTap: () => _showAllTagsDialog(context, tags),
            child: Chip(
              label: Text(
                "Ещё ${tags.length - renderedTags}",
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildDigestList(DigestProvider provider, List<Digest> digests) {
    if (provider.isLoading && digests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (digests.isEmpty) {
      return const Center(child: Text("Нет дайджестов"));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: digests.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == digests.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final digest = digests[index];
        return Card(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок дайджеста
                digest.title.text.bold.xl3
                    .color(
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    )
                    .size(12)
                    .make(),

                const SizedBox(height: 8),

                // Источники
                _buildSourcesText(digest.sources),

                const SizedBox(height: 8),

                // Текст дайджеста
                Text(
                  digest.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Тэги
                _buildTags(digest.tags),

                const SizedBox(height: 4),

                // Дата и кнопка Подробнее
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    digest.date.text
                        .size(14)
                        .color(Theme.of(context).textTheme.bodySmall!.color!)
                        .make(),
                    ElevatedButton(
                      onPressed: () {
                        // TODO Переход на страницу деталей дайджеста
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Переход к дайджесту: ${digest.title}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Подробнее',
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Дайджесты',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DigestSearchPage()),
            );
          },
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DigestProvider>(context);
    final digests = provider.digests;

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryButtons(provider),
          _buildSubscriptionsRow(),
          Expanded(child: _buildDigestList(provider, digests)),
        ],
      ),
    );
  }
}
