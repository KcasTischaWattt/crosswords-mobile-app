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
      final provider = Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.subscriptions.isEmpty) {
        provider.loadSubscriptions();
      }
    });
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
        final subscription = subscriptions[index];
        return _buildSubscriptionItem(subscription, provider);
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
      title: Text(subscription.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subscription.subscribeOptions.subscribed)
            IconButton(
              icon: Icon(subscription.subscribeOptions.mobileNotifications
                  ? Icons.notifications_active
                  : Icons.notifications_none),
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
              provider.updateSubscription(subscription.copyWith(
                subscribeOptions: subscription.subscribeOptions.copyWith(
                  subscribed: !subscription.subscribeOptions.subscribed,
                ),
              ));
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