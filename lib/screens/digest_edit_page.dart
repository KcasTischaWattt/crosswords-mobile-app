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
    provider.setMobileNotifications(widget.subscription.subscribeOptions.mobileNotifications);
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
    Provider.of<SubscriptionProvider>(context, listen: false).setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    Provider.of<SubscriptionProvider>(context, listen: false).setDescription(_descriptionController.text);
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
        'Редактирование подписки',
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
          child: TextField(
            controller: _recipientController,
            decoration: InputDecoration(
              hintText: 'Добавить получателя',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: () {
            if (_recipientController.text.isNotEmpty) {
              Provider.of<SubscriptionProvider>(context, listen: false)
                  .addFollower(_recipientController.text);
              _recipientController.clear();
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Название
              _buildSectionTitle("Название подписки"),
              TextField(controller: _titleController),

              const SizedBox(height: 16),

              // Описание
              _buildSectionTitle("Описание"),
              ExpandingTextField(
                controller: _descriptionController,
                hintText: "Опиcание...",
                maxLinesBeforeScroll: 7,
              ),

              const SizedBox(height: 16),

              // Чекбоксы "Уведомления"
              _buildSectionTitle("Настройки уведомлений"),
              _buildCheckboxTile(
                "Получать уведомления на почту",
                    (provider) => provider.sendToMail,
                    (provider, value) => provider.setSendToMail(value),
              ),
              _buildCheckboxTile(
                "Получать мобильные уведомления",
                    (provider) => provider.mobileNotifications,
                    (provider, value) => provider.setMobileNotifications(value),
              ),

              // Чекбокс "Сделать публичным"
              _buildCheckboxTile(
                "Сделать публичным",
                    (provider) => provider.isPublic,
                    (provider, value) => provider.setIsPublic(value),
              ),

              const SizedBox(height: 16),

              // Поле добавления получателя
              _buildSectionTitle("Добавить получателя"),
              _buildRecipientField(),

              // Отображение списка подписчиков
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
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Кнопки управления
              ActionButtons(
                onPrimaryPressed: _saveChanges,
                onSecondaryPressed: () => Navigator.pop(context),
                primaryText: 'Сохранить',
                secondaryText: 'Отмена',
                primaryIcon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
