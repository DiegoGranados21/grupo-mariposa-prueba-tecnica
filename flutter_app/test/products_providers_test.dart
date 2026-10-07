import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';

class PagedRepository implements ProductsRepository {
  final calls = <String>[];

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

      container.read(productsProvider.notifier).selectCategory('beauty');
      final category = await container.read(productsProvider.future);
      expect(category.items.single.id, 3);
      expect(repository.calls.last, 'beauty:0');
    },
  );
}
