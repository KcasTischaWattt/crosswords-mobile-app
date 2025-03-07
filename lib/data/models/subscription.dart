import 'subscribe_options.dart';

class Subscription {
  final int id;
  final String title;
  final String description;
  final List<String> sources;
  final List<String> tags;
  final SubscribeOptions subscribeOptions;
  final String creationDate;
  final bool public;
  final String owner;
  final bool isOwner;

  Subscription({
    required this.id,
    required this.title,
    required this.description,
    required this.sources,
    required this.tags,
    required this.subscribeOptions,
    required this.creationDate,
    required this.public,
    required this.owner,
    required this.isOwner,
  });

  Subscription copyWith({
    int? id,
    String? title,
    String? description,
    List<String>? sources,
    List<String>? tags,
    SubscribeOptions? subscribeOptions,
    String? creationDate,
    bool? public,
    String? owner,
    bool? isOwner,
  }) {
    return Subscription(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sources: sources ?? List.from(this.sources),
      tags: tags ?? List.from(this.tags),
      subscribeOptions: subscribeOptions ?? this.subscribeOptions,
      creationDate: creationDate ?? this.creationDate,
      public: public ?? this.public,
      owner: owner ?? this.owner,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      sources: List<String>.from(json['sources']),
      tags: List<String>.from(json['tags']),
      subscribeOptions: SubscribeOptions.fromJson(json['subscribe_options']),
      creationDate: json['creation_date'],
      public: json['public'],
      owner: json['owner'],
      isOwner: json['is_owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sources': sources,
      'tags': tags,
      'subscribe_options': subscribeOptions.toJson(),
      'creation_date': creationDate,
      'public': public,
      'owner': owner,
      'is_owner': isOwner,
    };
  }
}
