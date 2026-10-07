import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_screen.dart';

class FakeRepository implements ProductsRepository {
  static const phone = Product(
    id: 1,
    title: 'Phone',
    price: 10,
    rating: 4,
    thumbnail: '',
  );

  @override
  Future<Product> getProduct(int id) async => phone;

  @override
  Future<List<String>> getCategories() async => ['phones'];

  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async => const ProductPage(items: [phone], total: 1);
}

void main() {
  testWidgets('shows products from an overridden repository', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(FakeRepository()),
        ],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Categoría'), findsOneWidget);
  });
}
