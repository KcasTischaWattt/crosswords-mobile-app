import 'package:flutter/material.dart';
import '../providers/digest_provider.dart';
import '../data/models/digest.dart';
import 'package:provider/provider.dart';
import 'widgets/item_chips_list_widget.dart';
import 'widgets/custom_expansion_tile_widget.dart';

class DigestDetailPage extends StatefulWidget {
  final Digest digest;

  const DigestDetailPage({super.key, required this.digest});

  @override
  _DigestDetailPageState createState() => _DigestDetailPageState();
}

class _DigestDetailPageState extends State<DigestDetailPage> {

  void _showSettingsMenu(BuildContext context) {
    final bool isOwner = widget.digest.isOwner;
    final bool isSubscribed = widget.digest.subscribeOptions.subscribed;

    final menuItems = <Map<String, dynamic>>[];

    if (isOwner) {
      menuItems.add({
        'icon': Icons.edit,
        'text': "Редактировать",
        'action': () {
          Navigator.pop(context);
          //TODO Логика редактирования
        }
      });
    }

    if (isSubscribed) {
      menuItems.add({
        'icon': Icons.notifications,
        'text': "Настройка уведомлений",
        'action': () {
          Navigator.pop(context);
          _showNotificationSettingsDialog(context, widget.digest);
        }
      });
    }

    menuItems.add({
      'icon': isSubscribed ? Icons.unsubscribe : Icons.subscriptions,
      'text': isSubscribed ? "Отписаться" : "Подписаться",
      'action': () {
        Navigator.pop(context);
        _showUnsubscribeConfirmationDialog(context, widget.digest);
      }
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menuItems.map((item) {
              return ListTile(
                leading: Icon(item['icon'] as IconData, size: 28),
                title: Text(item['text'] as String, style: TextStyle(fontSize: 20)),
                onTap: item['action'] as VoidCallback,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showNotificationSettingsDialog(BuildContext context, Digest digest) {
    bool mobileNotifications = digest.subscribeOptions.mobileNotifications;
    bool emailNotifications = digest.subscribeOptions.sendToMail;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Настройки уведомлений"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text("Мобильные уведомления"),
                    value: mobileNotifications,
                    onChanged: (bool? value) {
                      setState(() {
                        mobileNotifications = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Уведомления на почту"),
                    value: emailNotifications,
                    onChanged: (bool? value) {
                      setState(() {
                        emailNotifications = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Отмена"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // TODO: Добавить логику сохранения настроек уведомлений
                  },
                  child: const Text("Применить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUnsubscribeConfirmationDialog(BuildContext context, Digest digest) {
    String message = digest.public
        ? "Вы уверены, что хотите отказаться от подписки?"
        : "Этот дайджест является приватным. Чтобы снова подписаться, вам нужно будет запросить разрешение у владельца. Вы уверены, что хотите отписаться?";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Отмена подписки"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (digest.isOwner) {
                  _showTransferOwnershipDialog(context, digest);
                } else {
                  //TODO Логика отписки
                }
              },
              child: const Text("Отписаться", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<String> _getPotentialOwners() {
    // TODO Логика получения списка потенциальных владельцев
    return [
      "User1",
      "User2",
      "User3",
      "User1",
      "User2",
      "User3",
      "User1",
      "User2",
      "User3",
      "User1",
      "User2",
      "User3",
      "User1",
      "User2",
      "User3"
    ];
  }

  void _showTransferOwnershipDialog(BuildContext context, Digest digest) {
    List<String> potentialOwners = _getPotentialOwners();

    if (potentialOwners.isEmpty) {
      _showUnsubscribeConfirmationDialog(context, digest);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String? selectedOwner;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Выберите нового владельца"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: potentialOwners.map((owner) {
                            return RadioListTile<String>(
                              title: Text(owner),
                              value: owner,
                              groupValue: selectedOwner,
                              onChanged: (value) {
                                setState(() {
                                  selectedOwner = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                TextButton(
                  onPressed: selectedOwner == null
                      ? null
                      : () {
                    Navigator.pop(context);
                    // TODO логика передачи владения
                  },
                  child: const Text("Передать и отписаться", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 60,
      centerTitle: true,
      title: Text(
        widget.digest.title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, size: 24),
          onPressed: () => _showSettingsMenu(context),
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  Widget _buildRatingExpansionTile(BuildContext context) {
    return CustomExpansionTile(
      title: "Оцените качество дайджеста",
      customContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < widget.digest.userRating ? Icons.star : Icons.star_border,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              final provider = Provider.of<DigestProvider>(context, listen: false);
              provider.setRating(index + 1, widget.digest);
            },
          );
        }),
      ), children: [],
    );
  }

  Widget _buildDateAndOwner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textStyle = DefaultTextStyle.of(context).style;
        final dateText = widget.digest.date;
        final ownerText = widget.digest.owner;
        final separator = " | ";

        final fullText = "$dateText$separator$ownerText";

        final textPainter = TextPainter(
          text: TextSpan(text: fullText, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final fitsInOneLine = textPainter.didExceedMaxLines == false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fitsInOneLine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fullText),
                  if (widget.digest.isOwner)
                    Icon(Icons.workspace_premium, size: 16),
                ],
              )
            else ...[
              Text(dateText),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.digest.isOwner)
                    Icon(Icons.workspace_premium, size: 16),
                  Expanded(
                    child: Text(
                      ownerText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Дата и владелец
              _buildDateAndOwner(),
              const SizedBox(height: 8),

              // Название дайджеста
              Text(
                widget.digest.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Описание дайджеста
              Text(widget.digest.description,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),

              // Теги
              ItemListWidget(
                items: widget.digest.tags,
                dialogTitle: "Все теги",
                chipColor: Theme.of(context).primaryColor,
                textColor: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),

              // Контент дайджеста
              Text(widget.digest.text),
              const SizedBox(height: 16),

              // Источники
              ItemListWidget(
                items: widget.digest.sources,
                dialogTitle: "Все источники",
                chipColor: Theme.of(context).secondaryHeaderColor,
                textColor: Colors.white,
                fontWeight: FontWeight.normal,
              ),
              const SizedBox(height: 16),

              // Аккордеон "Оцените качество дайджеста"
              _buildRatingExpansionTile(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
