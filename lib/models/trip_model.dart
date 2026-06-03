class TripModel {
  final String id;
  final String companyName;
  final double price;
  final String duration;
  final double rating;
  final bool isBookmarked;
  final String imageUrl;
  final bool isAvailable;

  TripModel({
    required this.id,
    required this.companyName,
    required this.price,
    required this.duration,
    required this.rating,
    required this.isBookmarked,
    required this.imageUrl,
    this.isAvailable = true,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] as String,
      rating: (json['rating'] as num).toDouble(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'price': price,
      'duration': duration,
      'rating': rating,
      'isBookmarked': isBookmarked,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}
