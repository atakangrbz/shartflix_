class Film {
  final int id;               // int tipine çevirdik
  final String title;
  final String description;
  final String posterUrl;
  bool isFavorite;

  Film({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    this.isFavorite = false,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()), // id int değilse parse et
      title: json['title'] as String,
      description: json['description'] as String,
      posterUrl: json['posterUrl'] as String,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  copyWith({required bool isFavorite}) {}
}
