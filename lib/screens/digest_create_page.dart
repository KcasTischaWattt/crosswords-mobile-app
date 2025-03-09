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
    _recipientController.text = provider.currentFollowerInput;

    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _recipientController.addListener(_onRecipientChanged);

    // TODO заменить на реального пользователя
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addDefault();
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _recipientController.removeListener(_onRecipientChanged);

    _titleController.dispose();
    _descriptionController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false)
        .setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false)
        .setDescription(_descriptionController.text);
  }

  void _onRecipientChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false)
        .setCurrentFollowerInput(_recipientController.text);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow = constraints.maxWidth <= 395;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isNarrow ? _buildCheckboxColumn() : _buildCheckboxRowLayout(),
            const SizedBox(height: 12),
            const Divider(thickness: 1, height: 20),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheckboxTile(
          "Почта",
          (provider) => provider.sendToMail,
          (provider, value) => provider.setSendToMail(value),
        ),
        _buildCheckboxTile(
          "Приложение",
          (provider) => provider.mobileNotifications,
          (provider, value) => provider.setMobileNotifications(value),
        ),
      ],
    );
  }

  Widget _buildCheckboxRowLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildCheckboxTile(
            "Почта",
            (provider) => provider.sendToMail,
            (provider, value) => provider.setSendToMail(value),
          ),
        ),
        Expanded(
          child: _buildCheckboxTile(
            "Приложение",
            (provider) => provider.mobileNotifications,
            (provider, value) => provider.setMobileNotifications(value),
          ),
        ),
      ],
    );
  }

  void _showManageFollowersDialog(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Управление подписчиками"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: provider.followers.map((user) {
                return ListTile(
                  title: Text(user),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, user);
                    },
                  ),
                );
              }).toList(),
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

  void _showDeleteConfirmationDialog(BuildContext context, String user) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Подтверждение удаления"),
          content: Text("Вы уверены, что хотите удалить '$user' из подписчиков?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Отмена
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () {
                provider.removeFollower(user);
                Navigator.pop(context);
                Navigator.pop(context);
                _showManageFollowersDialog(context);
              },
              child: const Text("Удалить", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool Function(SubscriptionProvider) getValue,
    void Function(SubscriptionProvider, bool) setValue,
  ) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, child) {
        return CheckboxListTile(
          title: Text(title),
          value: getValue(provider),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                setValue(provider, value);
              });
            }
          },
        );
      },
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
              controller: _recipientController,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Добавить получателя',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
    provider.resetAndAddDefault();
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

              Consumer<SubscriptionProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemListWidget(
                        items: provider.followers,
                        dialogTitle: "Все подписчики",
                        chipColor: Theme.of(context).primaryColor,
                        textColor: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                _showManageFollowersDialog(context),
                            child: Row(
                              children: [
                                Text("Настроить подписчиков",
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                const Icon(Icons.settings, size: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
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
