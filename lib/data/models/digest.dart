import 'subscribe_options.dart';

class Digest {
  final int id;
  final String title;
  final double averageRating;
  final int userRating;
  final List<String> sources;
  final String description;
  final String text;
  final List<String> tags;
  final String date;
  final bool public;
  final bool isOwner;
  final String owner;
  final List<String> urls;
  final SubscribeOptions subscribeOptions;

  Digest({
    required this.averageRating,
    required this.userRating,
    required this.public,
    required this.id,
    required this.title,
    required this.sources,
    required this.description,
    required this.text,
    required this.tags,
    required this.date,
    required this.isOwner,
    required this.owner,
    required this.urls,
    required this.subscribeOptions,
  });

  Digest copyWith({
    double? averageRating,
    int? userRating,
    bool? public,
    int? id,
    String? title,
    List<String>? sources,
    String? description,
    String? text,
    List<String>? tags,
    String? date,
    bool? isOwner,
    String? owner,
    List<String>? urls,
    SubscribeOptions? subscribeOptions,
  }) {
    return Digest(
      averageRating: averageRating ?? this.averageRating,
      userRating: userRating ?? this.userRating,
      public: public ?? this.public,
      id: id ?? this.id,
      title: title ?? this.title,
      sources: sources ?? List.from(this.sources),
      description: description ?? this.description,
      text: text ?? this.text,
      tags: tags ?? List.from(this.tags),
      date: date ?? this.date,
      isOwner: isOwner ?? this.isOwner,
      owner: owner ?? this.owner,
      urls: urls ?? List.from(this.urls),
      subscribeOptions: subscribeOptions ?? this.subscribeOptions,
    );
  }

  /// Метод для преобразования JSON в объект Digest
  factory Digest.fromJson(Map<String, dynamic> json) {
    return Digest(
      averageRating: json['averageRating'],
      userRating: json['userRating'],
      public: json['public'],
      id: json['id'],
      title: json['title'],
      sources: List<String>.from(json['sources']),
      description: json['description'],
      text: json['text'],
      tags: List<String>.from(json['tags']),
      date: json['date'],
      isOwner: json['isOwner'],
      owner: json['owner'],
      urls: List<String>.from(json['urls']),
      subscribeOptions: SubscribeOptions.fromJson(json['subscribeOptions']),
    );
  }

  /// Метод для преобразования объекта Digest в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'userRating': userRating,
      'averageRating': averageRating,
      'sources': sources,
      'description': description,
      'text': text,
      'tags': tags,
      'date': date,
      'public': public,
      'isOwner': isOwner,
      'owner': owner,
      'urls': urls,
      'subscribeOptions': subscribeOptions.toJson(),
    };
  }
}
