class SubscribeOptions {
  final bool subscribed;
  final bool sendToMail;
  final bool mobileNotifications;

  SubscribeOptions({
    required this.subscribed,
    required this.sendToMail,
    required this.mobileNotifications,
  });

  SubscribeOptions copyWith({
    bool? subscribed,
    bool? sendToMail,
    bool? mobileNotifications,
  }) {
    return SubscribeOptions(
      subscribed: subscribed ?? this.subscribed,
      sendToMail: sendToMail ?? this.sendToMail,
      mobileNotifications: mobileNotifications ?? this.mobileNotifications,
    );
  }

  factory SubscribeOptions.fromJson(Map<String, dynamic> json) {
    return SubscribeOptions(
      subscribed: json['subscribed'],
      sendToMail: json['send_to_mail'],
      mobileNotifications: json['mobile_notifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscribed': subscribed,
      'send_to_mail': sendToMail,
      'mobile_notifications': mobileNotifications,
    };
  }
}
