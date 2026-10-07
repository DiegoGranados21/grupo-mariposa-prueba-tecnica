import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/http_products_repository.dart';
import '../domain/product.dart';
import '../domain/product_page.dart';
import '../domain/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => HttpProductsRepository(),
);

final categoriesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(productsRepositoryProvider).getCategories(),
);

final productsProvider = AsyncNotifierProvider<ProductsNotifier, ProductPage>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<ProductPage> {
  Timer? _debounce;
  String _query = '';
  String _category = '';
  int _generation = 0;

  @override
  Future<ProductPage> build() {
    ref.onDispose(() => _debounce?.cancel());
    return ref.watch(productsRepositoryProvider).getProducts();
  }

  void search(String query) {
    _debounce?.cancel();
    final generation = ++_generation;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (generation != _generation) return;
      _query = query.trim();
      _category = '';
      _loadFirst();
    });
  }

  void selectCategory(String category) {
    _debounce?.cancel();
    ++_generation;
    _category = category;
    _query = '';
    _loadFirst();
  }

  Future<void> retry() => _loadFirst();

  Future<void> _loadFirst() async {
    final generation = ++_generation;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(productsRepositoryProvider)
          .getProducts(query: _query, category: _category),
    );
    if (generation == _generation) state = result;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null ||
        !current.hasMore ||
        current.loadingMore ||
        current.loadMoreError) {
      return;
    }
    final generation = _generation;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(productsRepositoryProvider)
          .getProducts(
            query: _query,
            category: _category,
            skip: current.items.length,
          );
      if (generation != _generation) return;
      state = AsyncData(
        ProductPage(
          items: [...current.items, ...next.items],
          total: next.total,
        ),
      );
    } on Object {
      if (generation == _generation) {
        state = AsyncData(
          current.copyWith(loadingMore: false, loadMoreError: true),
        );
      }
    }
  }

  void retryLoadMore() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(loadMoreError: false));
    unawaited(loadMore());
  }
}

final productDetailProvider = FutureProvider.autoDispose.family<Product, int>(
  (ref, id) => ref.watch(productsRepositoryProvider).getProduct(id),
);
