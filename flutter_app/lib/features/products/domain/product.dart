class Product {
  const Product({required this.id, required this.title, required this.price, required this.rating, required this.thumbnail, this.description = ''});
  final int id;
  final String title;
  final double price;
  final double rating;
  final String thumbnail;
  final String description;
  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        thumbnail: json['thumbnail'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );
}
