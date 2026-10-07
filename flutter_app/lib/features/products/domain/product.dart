import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.thumbnail,
    this.description = '',
  });
  final int id;
  final String title;
  final double price;
  final double rating;
  @JsonKey(defaultValue: '')
  final String thumbnail;
  @JsonKey(defaultValue: '')
  final String description;
  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
