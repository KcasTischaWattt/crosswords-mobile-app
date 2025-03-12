import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../data/models/subscription.dart';
import 'widgets/filter_expansion_panels.dart';
import 'widgets/expanding_text_field.dart';
import 'widgets/action_buttons.dart';
import 'widgets/item_chips_list_widget.dart';

class DigestEditPage extends StatefulWidget {
  final Subscription subscription;

  const DigestEditPage({super.key, required this.subscription});

  @override
  _DigestEditPageState createState() => _DigestEditPageState();
}

class _DigestEditPageState extends State<DigestEditPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // Загружаем данные подписки в провайдер
    provider.setTitle(widget.subscription.title);
    provider.setDescription(widget.subscription.description);
    provider.setFollowers(widget.subscription.followers);
    provider.setSendToMail(widget.subscription.subscribeOptions.sendToMail);
    provider.setSources(widget.subscription.sources);
    provider.setTags(widget.subscription.tags);
    provider.setMobileNotifications(
        widget.subscription.subscribeOptions.mobileNotifications);
    provider.setIsPublic(widget.subscription.public);

    _titleController.text = widget.subscription.title;
    _descriptionController.text = widget.subscription.description;

    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _recipientController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();

    Provider.of<SubscriptionProvider>(context, listen: false).reset();
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

  void _saveChanges() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    // Создаем обновленный объект подписки
    Subscription updatedSubscription = widget.subscription.copyWith(
      title: provider.title,
      description: provider.description,
      followers: provider.followers,
      subscribeOptions: widget.subscription.subscribeOptions.copyWith(
        sendToMail: provider.sendToMail,
        mobileNotifications: provider.mobileNotifications,
      ),
      public: provider.isPublic,
    );

    provider.updateSubscription(updatedSubscription);

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
        'Редактирование дайджеста',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
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

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Подтверждение выхода"),
            content: const Text(
                "Вы уверены, что хотите выйти? Все несохраненные данные будут потеряны."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Остаться"),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<SubscriptionProvider>(context, listen: false).reset();
                  Navigator.of(context).pop(true);
                },
                child: const Text("Выйти", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
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
            if (_recipientController.text.isNotEmpty) {
              _addFollower(_recipientController.text);
              _recipientController.clear();
            }
          },
        ),
      ],
    );
  }

  void _confirmResetFilters() {
    if (Provider.of<SubscriptionProvider>(context, listen: false)
        .areFieldsEmpty()) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Подтверждение сброса"),
            content: const Text(
                "Вы уверены, что хотите сбросить все поля? Это действие нельзя отменить."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Отмена"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetFilters();
                },
                child:
                    const Text("Сбросить", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    } else {
      _resetFilters();
    }
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
          content:
              Text("Вы уверены, что хотите удалить '$user' из подписчиков?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  void _resetFilters() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    provider.resetAndAddDefault();

    _titleController.text = provider.title;
    _descriptionController.text = provider.description;
    _recipientController.text = provider.currentFollowerInput;
  }

  Widget _buildSubscriptionNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Название дайджеста"),
        _buildDigestNameInput(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterSection(SubscriptionProvider provider) {
    return Column(
      children: [
        FilterExpansionPanels(provider: provider),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      children: [
        ExpandingTextField(
          controller: _descriptionController,
          hintText: "Опиcание...",
          maxLinesBeforeScroll: 7,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNotificationSettings(SubscriptionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Настройки уведомлений и приватности"),
        _buildCheckboxRow(),
        Consumer<SubscriptionProvider>(
          builder: (context, provider, child) {
            return CheckboxListTile(
              title: const Text("Сделать публичным"),
              value: provider.isPublic,
              onChanged: (value) {
                provider.setIsPublic(value!);
              },
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Добавить получателя"),
        _buildRecipientField(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFollowersSection() {
    return Consumer<SubscriptionProvider>(
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
                  onPressed: () => _showManageFollowersDialog(context),
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
    );
  }

  Widget _buildActionButtons() {
    return ActionButtons(
      onPrimaryPressed: _saveChanges,
      onSecondaryPressed: _confirmResetFilters,
      primaryText: 'Создать',
      secondaryText: 'Сбросить поля',
      primaryIcon: Icons.add,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        bool shouldExit = await _showExitConfirmationDialog(context);

        if (!context.mounted) return;

        if (shouldExit) {
          provider.reset();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubscriptionNameSection(),
                _buildFilterSection(provider),
                _buildDescriptionField(),
                _buildNotificationSettings(provider),
                _buildRecipientSection(),
                _buildFollowersSection(),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
