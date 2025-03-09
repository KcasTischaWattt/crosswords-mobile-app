import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'widgets/filter_expansion_panels.dart';
import 'widgets/expanding_text_field.dart';
import 'widgets/action_buttons.dart';

class DigestCreatePage extends StatefulWidget {
  const DigestCreatePage({super.key});

  @override
  _DigestCreatePageState createState() => _DigestCreatePageState();
}

class _DigestCreatePageState extends State<DigestCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  Widget _buildCheckboxRow() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Text("Уведомления на почту"),
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
            title: const Text("В мобильном приложении"),
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
          child: TextField(
            controller: _recipientController,
            decoration: const InputDecoration(
              labelText: "Добавить получателя",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      "Получатель \"${_recipientController.text}\" добавлен")),
            );
            _recipientController.clear();
          },
        ),
      ],
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
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Название",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Выбор тэгов и источников
              FilterExpansionPanels(provider: provider),
              const SizedBox(height: 16),

              // Описание
              ExpandingTextField(
                  controller: _descriptionController,
                  hintText: "Опиcание...",
                  maxLinesBeforeScroll: 7),
              const SizedBox(height: 16),

              // Чекбоксы "Уведомления"
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
              _buildRecipientField(),

              const SizedBox(height: 16),

              // Кнопка подтверждения
              ActionButtons(
                onPrimaryPressed: _createDigest,
                onSecondaryPressed: _resetFilters,
                primaryText: 'Создать',
                secondaryText: 'Сбросить поля',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
