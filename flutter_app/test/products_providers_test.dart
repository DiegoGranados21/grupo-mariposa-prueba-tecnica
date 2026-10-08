import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/catalog_filters.dart';

class PagedRepository implements ProductsRepository {
  final calls = <String>[];
  final queries = <String>[];
  bool fail = false;
  final pending = <String, Completer<ProductPage>>{};

  @override
  Future<List<String>> getCategories() async => ['beauty'];

  @override
  Future<Product> getProduct(int id) async => _product(id);

  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async {
    calls.add('$category:$skip');
    queries.add(query);
    if (fail) throw Exception('Prueba de error');
    if (pending.containsKey(query)) return pending[query]!.future;
    if (category.isNotEmpty) {
      return ProductPage(items: [_product(3)], total: 1);
    }
    return ProductPage(items: [_product(skip + 1)], total: 2);
  }

  Product _product(int id) => Product(
    id: id,
    title: 'Producto $id',
    price: 10,
    rating: 4,
    thumbnail: '',
  );
}

void main() {
  test('a late initial response cannot replace a completed search', () {
    fakeAsync((async) {
      final repository = PagedRepository();
      repository.pending[''] = Completer<ProductPage>();
      final container = ProviderContainer(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      );
      final notifier = container.read(productsProvider.notifier);
      notifier.search('phone');
      async.elapse(const Duration(milliseconds: 400));
      async.flushMicrotasks();
      expect(container.read(productsProvider).requireValue.items.single.id, 1);
      repository.pending['']!.complete(
        ProductPage(items: [repository._product(99)], total: 1),
      );
      async.flushMicrotasks();
      expect(container.read(productsProvider).requireValue.items.single.id, 1);
      container.dispose();
    });
  });

  test('search and category share one state and remain combined', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final filters = container.read(catalogFiltersProvider.notifier);
    filters.search('phone');
    filters.selectCategory('smartphones');
    expect(container.read(catalogFiltersProvider).query, 'phone');
    expect(container.read(catalogFiltersProvider).category, 'smartphones');
    filters.search('iphone');
    expect(container.read(catalogFiltersProvider).category, 'smartphones');
    filters.selectCategory('');
    expect(container.read(catalogFiltersProvider).query, 'iphone');
  });

  test('retries an initial loading error', () async {
    final repository = PagedRepository()..fail = true;
    final container = ProviderContainer(
      overrides: [productsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await expectLater(container.read(productsProvider.future), throwsException);
    repository.fail = false;
    await container.read(productsProvider.notifier).retry();
    expect(container.read(productsProvider).requireValue.items.single.id, 1);
  });

  test(
    'debounces input and keeps previous data while ignoring stale responses',
    () {
      fakeAsync((async) {
        final repository = PagedRepository();
        final container = ProviderContainer(
          overrides: [productsRepositoryProvider.overrideWithValue(repository)],
        );
        final notifier = container.read(productsProvider.notifier);
        async.flushMicrotasks();
        repository.pending['ph'] = Completer<ProductPage>();
        repository.pending['phone'] = Completer<ProductPage>();

        notifier.search('p');
        async.elapse(const Duration(milliseconds: 399));
        expect(repository.queries, ['']);
        notifier.search('ph');
        async.elapse(const Duration(milliseconds: 400));
        expect(repository.queries, ['', 'ph']);
        expect(container.read(productsProvider).isLoading, isTrue);
        expect(container.read(productsProvider).value!.items.single.id, 1);

        notifier.search('phone');
        async.elapse(const Duration(milliseconds: 400));
        final newer = ProductPage(items: [repository._product(7)], total: 1);
        repository.pending['phone']!.complete(newer);
        async.flushMicrotasks();
        repository.pending['ph']!.complete(
          ProductPage(items: [repository._product(2)], total: 1),
        );
        async.flushMicrotasks();
        expect(
          container.read(productsProvider).requireValue.items.single.id,
          7,
        );
        expect(container.read(catalogFiltersProvider).query, 'phone');
        container.dispose();
      });
    },
  );

  test(
    'preserves previous results on refresh error and retries the same filter',
    () async {
      final repository = PagedRepository();
      final container = ProviderContainer(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(productsProvider.future);
      repository.fail = true;
      container.read(productsProvider.notifier).selectCategory('beauty');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(productsProvider).hasError, isTrue);
      expect(container.read(productsProvider).value!.items.single.id, 1);
      repository.fail = false;
      await container.read(productsProvider.notifier).retry();
      expect(container.read(productsProvider).requireValue.items.single.id, 3);
      expect(repository.calls.last, 'beauty:0');
      expect(container.read(catalogFiltersProvider).category, 'beauty');
      expect(container.read(catalogFiltersProvider).query, isEmpty);
    },
  );

  test(
    'keeps the first page when loadMore fails and retries without duplicates',
    () async {
      final repository = PagedRepository();
      final container = ProviderContainer(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      await container.read(productsProvider.future);
      repository.fail = true;
      await container.read(productsProvider.notifier).loadMore();
      expect(
        container.read(productsProvider).requireValue.loadMoreError,
        isTrue,
      );
      expect(container.read(productsProvider).requireValue.items.length, 1);
      repository.fail = false;
      container.read(productsProvider.notifier).retryLoadMore();
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(productsProvider).requireValue.items.map((p) => p.id),
        [1, 2],
      );
      expect(
        container.read(productsProvider).requireValue.loadMoreError,
        isFalse,
      );
    },
  );

  test(
    'loads another page then starts over when the category changes',
    () async {
      final repository = PagedRepository();
      final container = ProviderContainer(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(
        (await container.read(productsProvider.future)).items.single.id,
        1,
      );
      await container.read(productsProvider.notifier).loadMore();
      expect(container.read(productsProvider).requireValue.items.length, 2);
      expect(repository.calls, [':0', ':1']);

      await container.read(productsProvider.notifier).selectCategory('beauty');
      final category = container.read(productsProvider).requireValue;
      expect(category.items.single.id, 3);
      expect(repository.calls.last, 'beauty:0');
    },
  );
}
