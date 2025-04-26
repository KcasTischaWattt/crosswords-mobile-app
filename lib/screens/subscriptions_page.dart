import 'package:crosswords/data/models/subscription.dart';
import 'package:crosswords/providers/subscription_provider.dart';
import 'package:crosswords/screens/widgets/loading_refresh_button.dart';
import 'package:crosswords/screens/widgets/subscription_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'digest_edit_page.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage>
    with SingleTickerProviderStateMixin {
  bool _showOnlySubscriptions = false;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadSubscriptions() {
    Future.microtask(() {
      if (!mounted) return;
      final provider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      if (provider.subscriptions.isEmpty) {
        provider.loadSubscriptions();
      }
    });
  }

  void _toggleSubscription(
      Subscription subscription, SubscriptionProvider provider) {
    provider.updateSubscription(subscription.copyWith(
      subscribeOptions: subscription.subscribeOptions.copyWith(
        subscribed: !subscription.subscribeOptions.subscribed,
      ),
    ));
  }

  void _confirmUnsubscribe(
      Subscription subscription, SubscriptionProvider provider) {
    if (subscription.isOwner) {
      _buildTransferOwnershipDialog(subscription, provider);
    } else {
      _toggleSubscription(subscription, provider);
    }
  }

  void _transferOwnership(Subscription subscription,
      SubscriptionProvider provider, String newOwner) {
    provider.transferOwnership(subscription, newOwner);
    _toggleSubscription(subscription, provider);
  }

  Widget _buildOnlySubscriptionsToggle() {
    final isAuthenticated = Provider.of<AuthProvider>(context).isAuthenticated;
    if (!isAuthenticated) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ChoiceChip(
          label: const Text("Только подписки"),
          selected: _showOnlySubscriptions,
          onSelected: (bool selected) {
            // TODO обновление списка подписок
            setState(() {
              _showOnlySubscriptions = selected;
            });
          },
        ),
      ),
    );
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
        return _buildSubscriptionItem(subscriptions[index], provider);
      },
    );
  }

  void _navigateToDigestsPage(int subscriptionId) {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    subscriptionProvider.setSelectedSubscription(subscriptionId);

    subscriptionProvider.setSelectedSubscription(subscriptionId);
    Navigator.pop(context);
  }

  Widget _buildSubscriptionItem(
      Subscription subscription, SubscriptionProvider provider) {
    return InkWell(
      onTap: () {
        _navigateToDigestsPage(subscription.id);
      },
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 60,
        child: ListTile(
          leading: SubscriptionAvatar(subscription: subscription),
          title: _buildTitle(subscription),
          trailing: _buildTrailingButtons(subscription, provider),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildTitle(Subscription subscription) {
    return Text(
      subscription.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildTrailingButtons(
      Subscription subscription, SubscriptionProvider provider) {
    final isAuthenticated = Provider.of<AuthProvider>(context).isAuthenticated;
    if (!isAuthenticated) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subscription.isOwner && subscription.subscribeOptions.subscribed)
          _buildEditButton(subscription),
        if (subscription.subscribeOptions.subscribed)
          _buildNotificationButton(subscription, provider),
        _buildSubscriptionToggleButton(subscription, provider),
      ],
    );
  }

  Widget _buildEditButton(Subscription subscription) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DigestEditPage(subscription: subscription),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(
      Subscription subscription, SubscriptionProvider provider) {
    return IconButton(
      icon: Icon(
        subscription.subscribeOptions.mobileNotifications
            ? Icons.notifications_active
            : Icons.notifications_none,
      ),
      onPressed: () {
        provider.updateSubscription(subscription.copyWith(
          subscribeOptions: subscription.subscribeOptions.copyWith(
            mobileNotifications:
                !subscription.subscribeOptions.mobileNotifications,
          ),
        ));
      },
    );
  }

  Widget _buildSubscriptionToggleButton(
      Subscription subscription, SubscriptionProvider provider) {
    return IconButton(
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
    );
  }

  void _buildUnsubscribeDialog(
      Subscription subscription, SubscriptionProvider provider) {
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
                child: const Text("Отмена")),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmUnsubscribe(subscription, provider);
              },
              child:
                  const Text("Отписаться", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _buildTransferOwnershipDialog(
      Subscription subscription, SubscriptionProvider provider) {
    List<String> potentialOwners = _getPotentialOwners();

    if (potentialOwners.isEmpty) {
      _buildUnsubscribeDialog(subscription, provider);
      return;
    }

    _showOwnershipDialog(subscription, provider, potentialOwners);
  }

  List<String> _getPotentialOwners() {
    // TODO получение списка пользователей
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

  void _showOwnershipDialog(Subscription subscription,
      SubscriptionProvider provider, List<String> potentialOwners) {
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
                          _transferOwnership(
                              subscription, provider, selectedOwner!);
                        },
                  child: const Text("Передать и отписаться",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);

    return AppBar(
      toolbarHeight: 60,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      title: const Text(
        'Темы дайджестов',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        LoadingRefreshButton(
          onRefresh: () async {
            await subscriptionProvider.loadSubscriptions();
          },
          isDisabled: subscriptionProvider.isLoading,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildOnlySubscriptionsToggle(),
          Expanded(
            child: Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return _buildSubscriptionList(provider);
              },
            ),
          ),
        ],
      ),
    );
  }
}
