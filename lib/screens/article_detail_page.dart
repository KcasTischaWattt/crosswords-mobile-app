import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../providers/article_provider.dart';
import '../data/models/article.dart';
import '../data/models/note.dart';

class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);


  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    await Provider.of<ArticleProvider>(context, listen: false).toggleFavorite(widget.article.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    final bool isFavorite = provider.favoriteArticles.contains(widget.article.id);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Детали статьи',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: provider.isLoading
                ? const CircularProgressIndicator()
                : Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey,
              size: 30,
            ),
            onPressed: provider.isLoading ? null : _toggleFavorite,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата и источник
            '${widget.article.date} | ${widget.article.source}'
                .text
                .xl
                .color(Theme.of(context).textTheme.bodySmall!.color!)
                .make(),
            const SizedBox(height: 8),

            // Заголовок статьи
            widget.article.title.text.bold.xl3.make(),
            const SizedBox(height: 16),

            // Тэги
            Wrap(
              spacing: 8,
              children: widget.article.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color(0xFF517ECF),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Аккордеон краткого содержания
            Container(
              decoration: BoxDecoration(
                color: (Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.grey[900]) as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    collapsedIconColor: Theme.of(context).iconTheme.color,
                    iconColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Row(
                    children: [
                      Icon(
                        Icons.book,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Краткое содержание',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: (Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.article.summary,
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.article.text,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Заголовок заметок
            const Text(
              'Заметки',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            // Список комментариев
            Consumer<ArticleProvider>(
              builder: (context, provider, child) {
                final notes = provider.getNotesForArticle(int.parse(widget.article.id));

                return notes.isEmpty
                    ? const Text("Заметок пока нет.")
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(note.text, style: const TextStyle(fontSize: 18)),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Оставить заметку...",
                      filled: true,
                      fillColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, size: 30),
                  onPressed: () {
                    final provider = Provider.of<ArticleProvider>(context, listen: false);
                    provider.addNote(int.parse(widget.article.id), _commentController.text);
                    _commentController.clear();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Кнопка для перехода на оригинальную статью
            ElevatedButton(
              onPressed: () {
                // Переход на оригинальную статью
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Переход по ссылке: ${widget.article.url}'),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Читать оригинал', style: TextStyle(color: Colors.black, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
