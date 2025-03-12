import 'package:crosswords/data/models/subscription.dart';
import 'package:crosswords/providers/subscription_provider.dart';
import 'package:crosswords/screens/base_digest_change_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DigestEditPage extends StatefulWidget {
  final Subscription subscription;

  const DigestEditPage({super.key, required this.subscription});

  @override
  _DigestEditPageState createState() => _DigestEditPageState();
}

class _DigestEditPageState extends BaseDigestPage<DigestEditPage> {
  @override
  void onInit(SubscriptionProvider provider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.setTitle(widget.subscription.title);
      provider.setDescription(widget.subscription.description);
      provider.setFollowers(widget.subscription.followers);
      provider.setSendToMail(widget.subscription.subscribeOptions.sendToMail);
      provider.setSources(widget.subscription.sources);
      provider.setTags(widget.subscription.tags);
      provider.setMobileNotifications(widget.subscription.subscribeOptions.mobileNotifications);
      provider.setIsPublic(widget.subscription.public);
    });
  }

  @override
  void onPrimaryPressed() {
    final provider = Provider.of<SubscriptionProvider>(context, listen: false);

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

  @override
  String getAppBarTitle() => "Редактирование дайджеста";

  @override
  String getFormTitle() => "Редактирование дайджеста";

  @override
  String getPrimaryButtonText() => "Сохранить";

  @override
  IconData getPrimaryButtonIcon() => Icons.save;
}
