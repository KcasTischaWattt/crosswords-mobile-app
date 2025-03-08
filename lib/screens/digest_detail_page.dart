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
  int _expandedPanel = -1;

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
                      index < widget.digest.userRating ? Icons.star : Icons.star_border,
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

  Widget _buildExpansionPanel() {
    return ExpansionPanelList.radio(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (index, isExpanded) {
        setState(() {
          _expandedPanel = isExpanded ? -1 : index;
        });
      },
      children: [
        ExpansionPanelRadio(
          value: 0,
          headerBuilder: (context, isExpanded) => const ListTile(title: Text("Теги")),
          body: _buildTagList(),
        ),
        ExpansionPanelRadio(
          value: 1,
          headerBuilder: (context, isExpanded) => const ListTile(title: Text("Источники")),
          body: _buildSourceList(),
        ),
      ],
    );
  }

  Widget _buildTagList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 8,
        children: widget.digest.tags
            .map((tag) => Chip(label: Text(tag)))
            .toList(),
      ),
    );
  }

  Widget _buildSourceList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.digest.sources.map((source) => Text("• $source")).toList(),
      ),
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
                  if (widget.digest.isOwner) Icon(Icons.workspace_premium, size: 16),
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
              Text(widget.digest.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),

              // Аккордеон "Оцените качество дайджеста"
              _buildRatingExpansionTile(context),
              const SizedBox(height: 16),

              // Контент дайджеста
              const SizedBox(height: 8),
              Text(widget.digest.text),
              const SizedBox(height: 16),

              // ExpansionPanelList с тегами и источниками
              _buildExpansionPanel(),
            ],
          ),
        ),
      ),
    );
  }
}
