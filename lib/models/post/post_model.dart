class PostModel {
  final String id;
  final String caption;
  final String imageUrl;
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  List<String>? likes;
  List<String>? comments;

  PostModel({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.likes,
    this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      caption: json['caption'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      authorId: json['authorId'],
      authorName: json['authorName'],
      likes: List<String>.from(json['likes'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'authorId': authorId,
      'authorName': authorName,
      'likes': likes ?? [],
      'comments': comments ?? [],
    };
  }
}