import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../data/models/subscription.dart';

class AllDigestTopicsPage extends StatefulWidget {
  const AllDigestTopicsPage({super.key});

  @override
  _AllDigestTopicsPageState createState() => _AllDigestTopicsPageState();
}

class _AllDigestTopicsPageState extends State<AllDigestTopicsPage> {
  bool _showOnlySubscriptions = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    Future.microtask(() {
      if (!mounted) return;
      final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.subscriptions.isEmpty) {
        provider.loadSubscriptions();
      }
    });
  }

  void _toggleSubscription(Subscription subscription, SubscriptionProvider provider) {
    provider.updateSubscription(subscription.copyWith(
      subscribeOptions: subscription.subscribeOptions.copyWith(
        subscribed: !subscription.subscribeOptions.subscribed,
      ),
    ));
  }

  void _confirmUnsubscribe(Subscription subscription, SubscriptionProvider provider) {
    if (subscription.isOwner) {
      _buildTransferOwnershipDialog(subscription, provider);
    } else {
      _handleUnsubscribe(subscription, provider);
    }
  }

  void _handleUnsubscribe(Subscription subscription, SubscriptionProvider provider) {
    _toggleSubscription(subscription, provider);
  }

  void _transferOwnership(Subscription subscription, SubscriptionProvider provider, String newOwner) {
    provider.transferOwnership(subscription, newOwner);
    _handleUnsubscribe(subscription, provider);
  }

  Widget _buildSubscriptionList(SubscriptionProvider provider) {
    final subscriptions = _showOnlySubscriptions
        ? provider.subscriptions.where((sub) => sub.subscribeOptions.subscribed).toList()
        : provider.subscriptions;

    if (subscriptions.isEmpty) {
      return const Center(child: Text("Нет подписок"));
    }

    return ListView.builder(
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        return _buildSubscriptionItem(subscriptions[index], provider);
      },
    );
  }

  Widget _buildSubscriptionItem(Subscription subscription, SubscriptionProvider provider) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey,
        child: Icon(Icons.category, color: Colors.white),
      ),
      title: Text(
        subscription.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subscription.isOwner && subscription.subscribeOptions.subscribed)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Редактирование: ${subscription.title}")),
              ),
            ),
          if (subscription.subscribeOptions.subscribed)
            IconButton(
              icon: Icon(
                subscription.subscribeOptions.mobileNotifications
                    ? Icons.notifications_active
                    : Icons.notifications_none,
              ),
              onPressed: () {
                provider.updateSubscription(subscription.copyWith(
                  subscribeOptions: subscription.subscribeOptions.copyWith(
                    mobileNotifications: !subscription.subscribeOptions.mobileNotifications,
                  ),
                ));
              },
            ),
          IconButton(
            icon: Icon(
              subscription.subscribeOptions.subscribed
                  ? Icons.check_circle
                  : Icons.add_circle_outline,
            ),
            onPressed: () {
              if (subscription.subscribeOptions.subscribed) {
                _buildUnsubscribeDialog(subscription, provider);
              } else {
                _toggleSubscription(subscription, provider);
              }
            },
          ),
        ],
      ),
    );
  }

  void _buildUnsubscribeDialog(Subscription subscription, SubscriptionProvider provider) {
    String message = subscription.public
        ? "Вы уверены, что хотите отказаться от подписки?"
        : "Этот дайджест является приватным. Чтобы снова подписаться, вам нужно будет запросить разрешение у владельца. Вы уверены, что хотите отписаться?";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Отмена подписки"),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmUnsubscribe(subscription, provider);
              },
              child: const Text("Отписаться", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _buildTransferOwnershipDialog(Subscription subscription, SubscriptionProvider provider) {
    List<String> potentialOwners = ["User1", "User2", "User3"];

    if (potentialOwners.isEmpty) {
      _buildUnsubscribeDialog(subscription, provider);
      return;
    }

    String? selectedOwner;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Выберите нового владельца"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
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
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
                TextButton(
                  onPressed: selectedOwner == null
                      ? null
                      : () {
                    Navigator.pop(context);
                    _transferOwnership(subscription, provider, selectedOwner!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: const Text(
          'Темы дайджестов',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: const Text("Только подписки"),
              selected: _showOnlySubscriptions,
              onSelected: (bool selected) {
                setState(() {
                  _showOnlySubscriptions = selected;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, child) => _buildSubscriptionList(provider),
            ),
          ),
        ],
      ),
    );
  }
}