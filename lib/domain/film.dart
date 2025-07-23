class Film {
  final int id;
  final String title;
  final bool isFavorite;

  Film({
    required this.id,
    required this.title,
    required this.isFavorite,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'],
      title: json['title'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
