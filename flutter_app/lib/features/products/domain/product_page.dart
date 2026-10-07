import 'product.dart';

class ProductPage {
  const ProductPage({
    required this.items,
    required this.total,
    this.loadingMore = false,
    this.loadMoreError = false,
  });

  final List<Product> items;
  final int total;
  final bool loadingMore;
  final bool loadMoreError;

  bool get hasMore => items.length < total;

  ProductPage copyWith({
    List<Product>? items,
    bool? loadingMore,
    bool? loadMoreError,
  }) => ProductPage(
    items: items ?? this.items,
    total: total,
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError ?? this.loadMoreError,
  );
}
