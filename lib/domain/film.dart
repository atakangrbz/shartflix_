class Film {
  final String id; // int → String olarak değişti
  final String title;
  final String description;
  final String posterUrl;
  final bool isFavorite;

  Film({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    this.isFavorite = false,
  });

  factory Film.fromJson(Map<String, dynamic> json) {
  return Film(
    id: json['id'] ?? '',
    title: json['Title'] ?? '',  // API’de büyük harflerle "Title"
    description: json['Plot'] ?? '', // Açıklama için "Plot"
    posterUrl: json['Poster'] ?? '',  // Burada alan adı Poster
    isFavorite: json['isFavorite'] ?? false,
  );
}


  Film copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    bool? isFavorite,
  }) {
    return Film(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
