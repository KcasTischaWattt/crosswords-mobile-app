import 'package:flutter/material.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'package:provider/provider.dart';
import 'widgets/item_chips_list_widget.dart';
import 'widgets/custom_expansion_tile_widget.dart';

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
    return CustomExpansionTile(
      title: "Оцените качество дайджеста",
      customContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < widget.digest.userRating ? Icons.star : Icons.star_border,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              final provider = Provider.of<DigestProvider>(context, listen: false);
              provider.setRating(index + 1, widget.digest);
            },
          );
        }),
      ), children: [],
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
              ItemListWidget(
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
              ItemListWidget(
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
