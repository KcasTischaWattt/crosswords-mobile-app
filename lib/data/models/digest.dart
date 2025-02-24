class Digest {
  final int id;
  final String title;
  final List<String> sources;
  final String text;
  final List<String> tags;
  final String date;
  final List<String> urls;
  final bool subscribed;

  Digest({
    required this.id,
    required this.title,
    required this.sources,
    required this.text,
    required this.tags,
    required this.date,
    required this.urls,
    required this.subscribed,
  });

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
      subscribed: json['subscribed'],
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
      'subscribed': subscribed,
    };
  }
}
