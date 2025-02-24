class Article {
  final String id;
  final String title;
  final String source;
  final String summary;
  final String text;
  final List<String> tags;
  final String date;
  final bool favorite;
  final String language;
  final String url;

  Article({
    required this.id,
    required this.title,
    required this.source,
    required this.summary,
    required this.text,
    required this.tags,
    required this.date,
    required this.favorite,
    required this.language,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      source: json['source'],
      summary: json['summary'],
      text: json['text'],
      tags: List<String>.from(json['tags'] ?? []),
      date: json['date'],
      favorite: json['favorite'] ?? false,
      language: json['language'],
      url: json['URL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'summary': summary,
      'text': text,
      'tags': tags,
      'date': date,
      'favorite': favorite,
      'language': language,
      'URL': url,
    };
  }
}
