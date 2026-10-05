import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/http_products_repository.dart';
import '../domain/product.dart';
import '../domain/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) => HttpProductsRepository());
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);
class SearchQueryNotifier extends Notifier<String> {
  @override String build() => '';
  void setQuery(String value) => state = value;
}
final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(ProductsNotifier.new);
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  Timer? _debounce;
  @override Future<List<Product>> build() => ref.watch(productsRepositoryProvider).getProducts();
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      ref.read(searchQueryProvider.notifier).setQuery(query);
      state = const AsyncLoading();
      state = await AsyncValue.guard(() => ref.read(productsRepositoryProvider).getProducts(query: query));
    });
    ref.onDispose(() => _debounce?.cancel());
  }
  Future<void> retry() async => state = await AsyncValue.guard(() => ref.read(productsRepositoryProvider).getProducts(query: ref.read(searchQueryProvider)));
}
final productDetailProvider = FutureProvider.autoDispose.family<Product, int>((ref, id) => ref.watch(productsRepositoryProvider).getProduct(id));
