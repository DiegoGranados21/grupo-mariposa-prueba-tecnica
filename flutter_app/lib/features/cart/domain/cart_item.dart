import '../../products/domain/product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});
  final Product product;
  final int quantity;
  double get subtotal => product.price * quantity;
  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };
}
