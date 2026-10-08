import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/http_products_repository.dart';
import '../domain/product.dart';
import '../domain/product_page.dart';
import '../domain/products_repository.dart';
import 'catalog_filters.dart';

part 'products_providers.g.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final repository = HttpProductsRepository();
  ref.onDispose(repository.close);
  return repository;
});

// Reintento explícito desde la UI; no repetir automáticamente un 404.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: noAutomaticRetry)
Future<List<String>> categories(Ref ref) =>
    ref.watch(productsRepositoryProvider).getCategories();

final productsProvider = AsyncNotifierProvider<ProductsNotifier, ProductPage>(
  ProductsNotifier.new,
  retry: noAutomaticRetry,
);

class ProductsNotifier extends AsyncNotifier<ProductPage> {
  Timer? _debounce;
  int _generation = 0;
  bool _disposed = false;

  @override
  Future<ProductPage> build() async {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      ++_generation;
      _debounce?.cancel();
    });
    final filters = ref.read(catalogFiltersProvider);
    final repository = ref.watch(productsRepositoryProvider);
    final generation = ++_generation;
    try {
      final page = await repository.getProducts(
        query: filters.query.trim(),
        category: filters.category,
      );
      // Si el usuario ya cambió filtros, la carga inicial debe seguir el
      // resultado vigente, no sobrescribirlo al terminar más tarde.
      if (!_disposed && generation != _generation) return await future;
      return page;
    } on Object {
      if (!_disposed && generation != _generation) return future;
      rethrow;
    }
  }

  void search(String query) {
    ref.read(catalogFiltersProvider.notifier).search(query);
    _debounce?.cancel();
    final generation = ++_generation;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (generation != _generation) return;
      _loadFirst();
    });
  }

  Future<void> selectCategory(String category) {
    ref.read(catalogFiltersProvider.notifier).selectCategory(category);
    _debounce?.cancel();
    ++_generation;
    return _loadFirst();
  }

  Future<void> retry() {
    _debounce?.cancel();
    return _loadFirst();
  }

  Future<void> _loadFirst() async {
    final generation = ++_generation;
    final filters = ref.read(catalogFiltersProvider);
    final page = state.value;
    if (page != null) {
      state = AsyncData(
        page.copyWith(loadingMore: false, loadMoreError: false),
      );
    }
    // Riverpod 3 conserva los datos previos al asignar carga o error.
    state = const AsyncLoading<ProductPage>();
    final result = await AsyncValue.guard(
      () => ref
          .read(productsRepositoryProvider)
          .getProducts(query: filters.query.trim(), category: filters.category),
    );
    if (!_disposed && generation == _generation) {
      state = result;
    }
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        state.isLoading ||
        state.hasError ||
        (_debounce?.isActive ?? false) ||
        !current.hasMore ||
        current.loadingMore ||
        current.loadMoreError) {
      return;
    }
    final generation = _generation;
    final filters = ref.read(catalogFiltersProvider);
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(productsRepositoryProvider)
          .getProducts(
            query: filters.query.trim(),
            category: filters.category,
            skip: current.items.length,
          );
      if (_disposed || generation != _generation) return;
      state = AsyncData(
        ProductPage(
          items: [...current.items, ...next.items],
          total: next.total,
        ),
      );
    } on Object {
      if (!_disposed && generation == _generation) {
        state = AsyncData(
          current.copyWith(loadingMore: false, loadMoreError: true),
        );
      }
    }
  }

  void retryLoadMore() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loadMoreError: false));
    unawaited(loadMore());
  }
}

@Riverpod(retry: noAutomaticRetry)
Future<Product> productDetail(Ref ref, int id) =>
    ref.watch(productsRepositoryProvider).getProduct(id);
