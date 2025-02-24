import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../data/fake/fake_digests.dart';
import '../data/models/digest.dart';

class DigestsPage extends StatelessWidget {
  const DigestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Дайджесты',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: fakeDigests.length,
        itemBuilder: (context, index) {
          final Digest digest = fakeDigests[index];

          return Card(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок дайджеста
                  digest.title.text.bold.xl3.color(
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ).make(),

                  const SizedBox(height: 8),

                  // Источники
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: digest.sources.map((source) {
                      return Chip(
                        label: Text(
                          source,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: const Color(0xFF517ECF),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

                  // Текст дайджеста (обрезаем на несколько строк)
                  digest.text.text
                      .color(Theme.of(context).textTheme.bodyMedium!.color!)
                      .maxLines(4)
                      .ellipsis
                      .make(),

                  const SizedBox(height: 8),

                  // Тэги
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: digest.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 8),

                  // Дата и кнопка Подробнее
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      digest.date.text.color(Theme.of(context).textTheme.bodySmall!.color!).make(),
                      ElevatedButton(
                        onPressed: () {
                          // Переход на страницу деталей дайджеста
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Переход к дайджесту: ${digest.title}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
      ),
    );
  }
}
