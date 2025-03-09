import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../data/models/subscribe_options.dart';
import 'widgets/filter_expansion_panels.dart';
import 'widgets/expanding_text_field.dart';

class DigestCreatePage extends StatefulWidget {
  const DigestCreatePage({super.key});

  @override
  _DigestCreatePageState createState() => _DigestCreatePageState();
}

class _DigestCreatePageState extends State<DigestCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  bool _sendToMail = false;
  bool _mobileNotifications = false;
  bool _isPublic = false;

  Widget _buildCheckboxRow() {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Text("Уведомления на почту"),
            value: _sendToMail,
            onChanged: (value) {
              setState(() {
                _sendToMail = value!;
              });
            },
          ),
        ),
        Expanded(
          child: CheckboxListTile(
            title: const Text("В мобильном приложении"),
            value: _mobileNotifications,
            onChanged: (value) {
              setState(() {
                _mobileNotifications = value!;
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
              SnackBar(content: Text("Получатель \"${_recipientController.text}\" добавлен")),
            );
            _recipientController.clear();
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton(SubscriptionProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_titleController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Название не может быть пустым")),
            );
            return;
          }

          // TODO добавить создание подписки

          Navigator.pop(context);
        },
        child: const Text("Подтвердить"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Заказ дайджеста"),
      ),
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
              ExpandingTextField(controller: _descriptionController),
              const SizedBox(height: 16),

              // Чекбоксы "Уведомления"
              _buildCheckboxRow(),

              // Чекбокс "Сделать публичным"
              CheckboxListTile(
                title: const Text("Сделать публичным"),
                value: _isPublic,
                onChanged: (value) {
                  setState(() {
                    _isPublic = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Поле добавления получателя
              _buildRecipientField(),

              const SizedBox(height: 16),

              // Кнопка подтверждения
              _buildConfirmButton(provider),
            ],
          ),
        ),
      ),
    );
  }
}