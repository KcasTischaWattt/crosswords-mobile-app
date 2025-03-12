import 'package:crosswords/screens/widgets/digest_components/digest_app_bar.dart';
import 'package:crosswords/screens/widgets/digest_components/digest_form.dart';
import 'package:crosswords/screens/widgets/digest_components/exit_confirmation_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) => provider.addDefault());
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

  void _createDigest() {
    // TODO: Добавить логику создания дайджеста
    Navigator.pop(context);
  }

  void _resetFilters() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    provider.resetAndAddDefault();

    _titleController.text = provider.title;
    _descriptionController.text = provider.description;
    _recipientController.text = provider.currentFollowerInput;
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
  @override
  Widget build(BuildContext context) {
    return ExitConfirmationHandler(
      onExitRequested: (context) async => true,
      child: Scaffold(
        appBar: const DigestAppBar(title: 'Создание дайджеста'),
        body: Padding(
          padding: const EdgeInsets.all(1.0),
          child: DigestForm(
            titleController: _titleController,
            descriptionController: _descriptionController,
            recipientController: _recipientController,
            onPrimaryPressed: _createDigest,
            onSecondaryPressed: _confirmResetFilters,
            formTitle: 'Создание дайджеста',
            primaryButtonText: 'Создать',
            primaryButtonIcon: Icons.add,
          ),
        ),
      ),
    );
  }
}
