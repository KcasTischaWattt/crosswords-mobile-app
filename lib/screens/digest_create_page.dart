import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'widgets/filter_expansion_panels.dart';
import 'widgets/expanding_text_field.dart';
import 'widgets/action_buttons.dart';
import 'widgets/item_chips_list_widget.dart';

class DigestCreatePage extends StatefulWidget {
  const DigestCreatePage({super.key});

  @override
  _DigestCreatePageState createState() => _DigestCreatePageState();
}

class _DigestCreatePageState extends State<DigestCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    _titleController.text = provider.title;
    _descriptionController.text = provider.description;

    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);

    // TODO заменить на реального пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addFollower("default");
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);

    _titleController.dispose();
    _descriptionController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false).setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false).setDescription(_descriptionController.text);
  }


  Widget _buildDigestNameInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Название',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildCheckboxRow() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Text("Почта"),
            value: provider.sendToMail,
            onChanged: (value) {
              setState(() {
                provider.setSendToMail(value!);
              });
            },
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            title: const Text("Приложение"),
            value: provider.mobileNotifications,
            onChanged: (value) {
              setState(() {
                provider.setMobileNotifications(value!);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Добавить получателя',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: () {
            _addFollower(_recipientController.text);
            _recipientController.clear();
          },
        ),
      ],
    );
  }

  void _addFollower(String follower) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    if (!provider.addFollower(follower)) {
      _showErrorDialogMessage();
    }
  }

  void _showErrorDialogMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ошибка"),
          content: const Text("Пользователь уже добавлен"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: const Text(
        'Заказ дайджеста',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _createDigest() {
    // TODO добавить создание дайджеста
    Navigator.pop(context);
  }

  void _resetFilters() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    // TODO добавить сброс фильтров
    // provider.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название подписки
              _buildSectionTitle("Название подписки"),
              _buildDigestNameInput(),
              const SizedBox(height: 16),

              // Выбор тэгов и источников
              FilterExpansionPanels(provider: provider),
              const SizedBox(height: 16),

              // Описание,
              ExpandingTextField(
                  controller: _descriptionController,
                  hintText: "Опиcание...",
                  maxLinesBeforeScroll: 7),
              const SizedBox(height: 16),

              // Чекбоксы "Уведомления"
              _buildSectionTitle("Настройки уведомлений и приватности"),
              _buildCheckboxRow(),

              // Чекбокс "Сделать публичным"
              CheckboxListTile(
                title: const Text("Сделать публичным"),
                value: provider.isPublic,
                onChanged: (value) {
                  setState(() {
                    provider.setIsPublic(value!);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Поле добавления получателя
              _buildSectionTitle("Добавить получателя"),
              _buildRecipientField(),
              const SizedBox(height: 16),

              ItemListWidget(
                items: provider.followers,
                dialogTitle: "Все подписчики",
                chipColor: Theme.of(context).primaryColor,
                textColor: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // Кнопка подтверждения
              ActionButtons(
                onPrimaryPressed: _createDigest,
                onSecondaryPressed: _resetFilters,
                primaryText: 'Создать',
                secondaryText: 'Сбросить поля',
                primaryIcon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
