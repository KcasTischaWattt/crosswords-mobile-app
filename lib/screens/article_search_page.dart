import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import 'widgets/filter_expansion_panels.dart';

class ArticleSearchPage extends StatefulWidget {
  const ArticleSearchPage({super.key});

  @override
  _ArticleSearchPageState createState() => _ArticleSearchPageState();
}

class _ArticleSearchPageState extends State<ArticleSearchPage> {
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
    _toggleSearchExpansion();
  }

  void _toggleSearchExpansion() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
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

  // Виджет AppBar
  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: const Text(
        'Поиск статей',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Декорация контейнера аккордеона выбора типа поиска
  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: 1,
      ),
    );
  }

  // Заголовок аккордеона выбора типа поиска
  Widget _buildAccordionHeader(ArticleProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          provider.selectedSearchOption,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Icon(
          _isSearchExpanded
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          size: 24,
        ),
      ],
    );
  }

  // Содержимое аккордеона выбора типа поиска
  Widget _buildAccordionContent() {
    return AnimatedSize(
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
    );
  }

  // Аккордеон выбора типа поиска
  Widget _buildSearchAccordion(ArticleProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: GestureDetector(
        onTap: _toggleSearchExpansion,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: _containerDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccordionHeader(provider),
              _buildAccordionContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Строка поиска
  Widget _buildSearchInput() {
    return Container(
      decoration: _containerDecoration(),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Строка поиска',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    );
  }

  // Чекбокс "Искать в тексте"
  Widget _buildCheckbox(ArticleProvider provider) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Искать в тексте',
        style: TextStyle(fontSize: 14),
      ),
      value: provider.searchInText,
      onChanged: (bool? value) => provider.setSearchInText(value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // Виджет фильтров
  Widget _buildFilters(ArticleProvider provider) {
    return Column(
      children: [
        Consumer<ArticleProvider>(
          builder: (context, provider, child) {
            return FilterExpansionPanels(provider: provider);
          },
        ),
        const SizedBox(height: 16),
        _buildDatePickers(),
      ],
    );
  }

  // Поля выбора даты
  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(child: _buildDatePickerField('Дата С', _dateFromController)),
        const SizedBox(width: 12),
        Expanded(child: _buildDatePickerField('Дата По', _dateToController)),
      ],
    );
  }

  // Поле выбора даты
  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(fontSize: 16),
        onTap: () => _selectDate(context, controller),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  // Кнопки "Найти" и "Сбросить фильтры"
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _performSearch,
            child: const Text('Найти', style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: _resetFilters,
          child: const Text('Сбросить фильтры', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAccordion(provider),
              const SizedBox(height: 10),
              _buildSearchInput(),
              if (provider.selectedSearchOption == 'Точный поиск') _buildCheckbox(provider),
              if (provider.selectedSearchOption != 'Поиск по ID') _buildFilters(provider),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
