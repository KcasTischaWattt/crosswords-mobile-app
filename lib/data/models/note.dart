class Note {
  final int id;
  final String text;
  final String user;
  final int articleId;
  final String createdAt;
  final String updatedAt;

  Note({
    required this.id,
    required this.text,
    required this.user,
    required this.articleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      text: json['text'],
      user: json['user'],
      articleId: json['articleId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'user': user,
      'articleId': articleId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Note copyWith({required String text, required String updatedAt}) {
    return Note(
      id: id,
      text: text,
      user: user,
      articleId: articleId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}