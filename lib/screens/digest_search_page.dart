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

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: const Text(
        'Поиск дайджестов',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
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
    );
  }

  Widget _buildFilters(DigestProvider provider) {
    return Consumer<DigestProvider>(
      builder: (context, provider, child) {
        return FilterExpansionPanels(provider: provider);
      },
    );
  }

  Widget _buildDatePickers() {
    return Row(
      children: [
        Expanded(child: _buildDatePickerField('Дата С', _dateFromController)),
        const SizedBox(width: 12),
        Expanded(child: _buildDatePickerField('Дата По', _dateToController)),
      ],
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Container(
      decoration: _containerDecoration(),
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
    final provider = Provider.of<DigestProvider>(context);
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchInput(),
              const SizedBox(height: 16),
              _buildFilters(provider),
              const SizedBox(height: 16),
              _buildDatePickers(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
