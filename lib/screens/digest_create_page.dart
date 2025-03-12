import 'package:crosswords/providers/subscription_provider.dart';
import 'package:crosswords/screens/base_digest_change_page.dart';
import 'package:flutter/material.dart';

class DigestCreatePage extends StatefulWidget {
  const DigestCreatePage({super.key});

  @override
  _DigestCreatePageState createState() => _DigestCreatePageState();
}

class _DigestCreatePageState extends BaseDigestPage<DigestCreatePage> {
  @override
  void onInit(SubscriptionProvider provider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addDefault();
    });
  }

  @override
  void onPrimaryPressed() {
    // TODO: Добавить логику создания дайджеста
    Navigator.pop(context);
  }

  @override
  String getAppBarTitle() => "Создание дайджеста";

  @override
  String getFormTitle() => "Создание дайджеста";

  @override
  String getPrimaryButtonText() => "Создать";

  @override
  IconData getPrimaryButtonIcon() => Icons.add;
}
