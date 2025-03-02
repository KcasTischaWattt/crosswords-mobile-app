import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/article_provider.dart';

class FilterExpansionPanels extends StatefulWidget {
  const FilterExpansionPanels({super.key});

  @override
  State<FilterExpansionPanels> createState() => _FilterExpansionPanelsState();
}

class _FilterExpansionPanelsState extends State<FilterExpansionPanels> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ExpansionPanelList.radio(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        children: [
          ExpansionPanelRadio(
            value: 'sources',
            canTapOnHeader: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  'Источники',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            body: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SingleChildScrollView(
                child: Column(
                  children: provider.sources.map((item) {
                    return CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      title: Text(item, style: const TextStyle(fontSize: 14)),
                      value: provider.selectedSources.contains(item),
                      onChanged: (bool? value) {
                        setState(() {
                          provider.toggleSource(item);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // теги
          ExpansionPanelRadio(
            value: 'tags',
            canTapOnHeader: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  'Тэги',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            body: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              constraints: const BoxConstraints(maxHeight: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SingleChildScrollView(
                child: Column(
                  children: provider.tags.map((item) {
                    return CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                      title: Text(item, style: const TextStyle(fontSize: 14)),
                      value: provider.selectedTags.contains(item),
                      onChanged: (bool? value) {
                        setState(() {
                          provider.toggleTag(item);
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
