import 'package:flutter/material.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'package:provider/provider.dart';

class DigestDetailPage extends StatefulWidget {
  final Digest digest;

  const DigestDetailPage({super.key, required this.digest});

  @override
  _DigestDetailPageState createState() => _DigestDetailPageState();
}

class _DigestDetailPageState extends State<DigestDetailPage> {
  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      centerTitle: true,
      title: Text(
        widget.digest.title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, size: 24),
          onPressed: () {
            // TODO открыть настройки дайджеста
          },
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildRatingExpansionTile(BuildContext context) {
    final provider = Provider.of<DigestProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: (Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
            Colors.grey[900]) as Color,
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
              const Text(
                'Оцените качество дайджеста',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: (Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor ??
                    Colors.white),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < widget.digest.userRating
                          ? Icons.star
                          : Icons.star_border,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        provider.setRating(index + 1, widget.digest);
                      });
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Универсальный метод построения списка источников и тэгов
  Widget _buildItemList({
    required List<String> items,
    required String dialogTitle,
    required Color chipColor,
    required Color textColor,
    required FontWeight fontWeight,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    double screenWidth = MediaQuery.of(context).size.width;
    int itemLimit = screenWidth <= 350 ? 3 : 4;
    int renderedItems = items.length > itemLimit ? itemLimit - 1 : items.length;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...items.take(renderedItems).map((item) => Chip(
              label: Text(item,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: fontWeight)),
              backgroundColor: chipColor,
            )),
        if (items.length > itemLimit)
          GestureDetector(
            onTap: () => _showAllItemsDialog(context, items, dialogTitle),
            child: Chip(
              label: Text(
                "Ещё ${items.length - renderedItems}",
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: fontWeight),
              ),
              backgroundColor: chipColor,
            ),
          ),
      ],
    );
  }

  /// Универсальный метод для диалогового окна
  void _showAllItemsDialog(
      BuildContext context, List<String> items, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: items
                  .map((item) => Text(
                        item,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Дата и владелец
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${widget.digest.date} | "),
                  if (widget.digest.isOwner)
                    Icon(Icons.workspace_premium, size: 16),
                  Text(" ${widget.digest.owner}"),
                ],
              ),
              const SizedBox(height: 8),

              // Название дайджеста
              Text(
                widget.digest.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Описание дайджеста
              Text(widget.digest.description,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),

              // Теги
              _buildItemList(
                items: widget.digest.tags,
                dialogTitle: "Все теги",
                chipColor: Theme.of(context).primaryColor,
                textColor: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // Контент дайджеста
              Text(widget.digest.text),
              const SizedBox(height: 16),

              // Источники
              _buildItemList(
                items: widget.digest.sources,
                dialogTitle: "Все источники",
                chipColor: Theme.of(context).secondaryHeaderColor,
                textColor: Colors.white,
                fontWeight: FontWeight.normal,
              ),
              const SizedBox(height: 16),

              // Аккордеон "Оцените качество дайджеста"
              _buildRatingExpansionTile(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
