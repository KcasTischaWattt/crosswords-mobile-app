import 'subscribe_options.dart';

class Digest {
  final int id;
  final String title;
  final List<String> sources;
  final String text;
  final List<String> tags;
  final String date;
  final List<String> urls;
  final SubscribeOptions subscribeOptions;

  Digest({
    required this.id,
    required this.title,
    required this.sources,
    required this.text,
    required this.tags,
    required this.date,
    required this.urls,
    required this.subscribeOptions,
  });

  Digest copyWith({
    int? id,
    String? title,
    List<String>? sources,
    String? text,
    List<String>? tags,
    String? date,
    List<String>? urls,
    SubscribeOptions? subscribeOptions,
  }) {
    return Digest(
      id: id ?? this.id,
      title: title ?? this.title,
      sources: sources ?? List.from(this.sources),
      text: text ?? this.text,
      tags: tags ?? List.from(this.tags),
      date: date ?? this.date,
      urls: urls ?? List.from(this.urls),
      subscribeOptions: subscribeOptions ?? this.subscribeOptions,
    );
  }

  // Метод для преобразования JSON в объект Digest
  factory Digest.fromJson(Map<String, dynamic> json) {
    return Digest(
      id: json['id'],
      title: json['title'],
      sources: List<String>.from(json['sources']),
      text: json['text'],
      tags: List<String>.from(json['tags']),
      date: json['date'],
      urls: List<String>.from(json['urls']),
      subscribeOptions: SubscribeOptions.fromJson(json['subscribeOptions']),
    );
  }

  // Метод для преобразования объекта Digest в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sources': sources,
      'text': text,
      'tags': tags,
      'date': date,
      'urls': urls,
      'subscribeOptions': subscribeOptions.toJson(),
    };
  }
}
