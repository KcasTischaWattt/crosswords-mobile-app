import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import 'widgets/filter_expansion_panels.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  late TextEditingController _dateFromController;
  late TextEditingController _dateToController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<ArticleProvider>(context, listen: false);
    _searchController = TextEditingController(text: provider.searchQuery);
    _dateFromController = TextEditingController(text: provider.dateFrom);
    _dateToController = TextEditingController(text: provider.dateTo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateFromController.dispose();
    _dateToController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    Provider.of<ArticleProvider>(context, listen: false).resetFilters();
  }

  void _setSearchOption(String option) {
    Provider.of<ArticleProvider>(context, listen: false)
        .setSearchOption(option);
    toggleSearchExpansion();
  }

  void toggleSearchExpansion() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked
          .toIso8601String()
          .split('T')
          .first;
    }
  }

  void _performSearch() {
    // final provider = Provider.of<ArticleProvider>(context, listen: false);
    // provider.updateSearchQuery(_searchController.text);
    // provider.updateDateRange(_dateFromController.text, _dateToController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск статей'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аккордеон
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  toggleSearchExpansion();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.selectedSearchOption,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            _isSearchExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 24,
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isSearchExpanded
                            ? Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 6),
                              title: const Text('Поиск по смыслу'),
                              onTap: () => _setSearchOption('Поиск по смыслу'),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 6),
                              title: const Text('Точный поиск'),
                              onTap: () => _setSearchOption('Точный поиск'),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.only(top: 6, bottom: 0),
                              title: const Text('Поиск по ID'),
                              onTap: () => _setSearchOption('Поиск по ID'),
                            ),
                          ],
                        )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Строка поиска
            Container(
              decoration: BoxDecoration(
                color:
                Theme
                    .of(context)
                    .bottomNavigationBarTheme
                    .backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Поле ввода
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Строка поиска',
                        hintStyle:
                        TextStyle(color: Colors.grey[600], fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 24,
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
                  style: TextStyle(fontSize: 14),
                ),
                value: provider.searchInText,
                onChanged: (bool? value) =>
                    provider.setSearchInText(value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],

            // Фильтры и даты
            if (provider.selectedSearchOption != 'Поиск по ID') ...[
              const SizedBox(height: 16),

              const FilterExpansionPanels(),

              const SizedBox(height: 16),

              // Поля выбора даты
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .bottomNavigationBarTheme
                            .backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _dateFromController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 16),
                        onTap: () => _selectDate(context, _dateFromController),
                        decoration: const InputDecoration(
                          labelText: 'Дата С',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .bottomNavigationBarTheme
                            .backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _dateToController,
                        readOnly: true,
                        style: const TextStyle(fontSize: 16),
                        onTap: () => _selectDate(context, _dateToController),
                        decoration: const InputDecoration(
                          labelText: 'Дата По',
                          labelStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
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
                      backgroundColor: Theme
                          .of(context)
                          .primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _performSearch();
                    },
                    child: const Text('Найти',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Сбросить фильтры',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}