import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'all_digest_topics_page.dart';

class DigestsPage extends StatefulWidget {
  const DigestsPage({super.key});

  @override
  _DigestsPageState createState() => _DigestsPageState();
}

class _DigestsPageState extends State<DigestsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<DigestProvider>(context, listen: false).loadDigests();
    });
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
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => provider.setCategory(category),
              ),
            );
          }),
    );
  }

  Widget _buildSubscriptionsRow() {
    return SizedBox(
      height: 90,
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
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person,
                            size: 30, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text("Дайджест $index",
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        Container(
          width: 60,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
          ),
          child: TextButton(
            onPressed: () {
              // Действие при нажатии
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllDigestTopicsPage()),
              );
            },
            child: const Text(
              "Все",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ),
      ]),
    );
  }

  // Строки с источниками
  Widget _buildSourcesText(List<String> sources) {
    if (sources.isEmpty) return const SizedBox.shrink();

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
          style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ));
        if (i < sources.length - 1) {
          spans.add(const TextSpan(text: ", ", style: TextStyle(fontWeight: FontWeight.normal)));
        }
      }
    } else {
      spans.add(TextSpan(
        text: sources[0],
        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
      ));
      spans.add(const TextSpan(text: ", ", style: TextStyle(fontWeight: FontWeight.normal)));

      spans.add(TextSpan(
        text: sources[1],
        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
      ));
      spans.add(const TextSpan(text: " и ", style: TextStyle(fontWeight: FontWeight.normal)));

      spans.add(TextSpan(
        text: "ещё ${sources.length - 2}",
        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
    );
  }

  Widget _buildDigestList(DigestProvider provider, List<Digest> digests) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (digests.isEmpty) {
      return const Center(child: Text("Нет дайджестов"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: digests.length,
      itemBuilder: (context, index) {
        final digest = digests[index];
        return Card(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Тэги
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: digest.tags.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DigestProvider>(context);
    final digests = provider.digests;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Дайджесты',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
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
