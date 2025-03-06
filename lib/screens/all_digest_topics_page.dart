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
    Future.microtask(() {
      if (!mounted) return;
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.subscriptions.isEmpty) {
        provider.loadSubscriptions();
      }
    });
  }

  Widget _buildSubscriptionList(SubscriptionProvider provider) {
    final subscriptions = _showOnlySubscriptions
        ? provider.subscriptions
            .where((sub) => sub.subscribeOptions.subscribed)
            .toList()
        : provider.subscriptions;

    if (subscriptions.isEmpty) {
      return const Center(child: Text("Нет подписок"));
    }

    return ListView.builder(
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final subscription = subscriptions[index];
        return _buildSubscriptionItem(subscription, provider);
      },
    );
  }

  void _showUnsubscribeDialog(Subscription subscription, SubscriptionProvider provider) {
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Отмена"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleSubscription(subscription, provider);
              },
              child: const Text("Отписаться", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _toggleSubscription(Subscription subscription, SubscriptionProvider provider) {
    provider.updateSubscription(subscription.copyWith(
      subscribeOptions: subscription.subscribeOptions.copyWith(
        subscribed: !subscription.subscribeOptions.subscribed,
      ),
    ));
  }

  Widget _buildSubscriptionItem(
      Subscription subscription, SubscriptionProvider provider) {
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Редактирование: ${subscription.title}")),
                );
              },
            ),
          if (subscription.subscribeOptions.subscribed)
            IconButton(
              icon: Icon(subscription.subscribeOptions.mobileNotifications
                  ? Icons.notifications_active
                  : Icons.notifications_none),
              onPressed: () {
                provider.updateSubscription(subscription.copyWith(
                  subscribeOptions: subscription.subscribeOptions.copyWith(
                    mobileNotifications:
                        !subscription.subscribeOptions.mobileNotifications,
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
                _showUnsubscribeDialog(subscription, provider);
              } else {
                _toggleSubscription(subscription, provider);
              }
            },
          ),
        ],
      ),
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
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text("Только подписки"),
                  selected: _showOnlySubscriptions,
                  onSelected: (bool selected) {
                    setState(() {
                      _showOnlySubscriptions = selected;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return _buildSubscriptionList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }
}
