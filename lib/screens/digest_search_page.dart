import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/digest_provider.dart';
import 'widgets/filter_expansion_panels.dart';

class DigestSearchPage extends StatefulWidget {
  const DigestSearchPage({super.key});

  @override
  _DigestSearchPageState createState() => _DigestSearchPageState();
}

class _DigestSearchPageState extends State<DigestSearchPage> {
  late TextEditingController _searchController;
  late TextEditingController _dateFromController;
  late TextEditingController _dateToController;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<DigestProvider>(context, listen: false);
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
    Provider.of<DigestProvider>(context, listen: false).resetFilters();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
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
    final provider = Provider.of<DigestProvider>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: const Text(
          'Поиск дайджестов',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Строка поиска
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context)
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

              const SizedBox(height: 16),
              // Тэги и источники
              Consumer<DigestProvider>(
                builder: (context, provider, child) {
                  return FilterExpansionPanels(provider: provider);
                },
              ),

              const SizedBox(height: 16),

              // Поля выбора даты
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
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
                        color: Theme.of(context)
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

              const SizedBox(height: 16),

              // Кнопки "Найти" и "Сбросить фильтры"
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
