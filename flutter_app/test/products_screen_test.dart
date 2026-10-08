import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_screen.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/catalog_failure.dart';

class EmptyRepository extends FakeRepository {
  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async => ProductPage(items: [], total: 0);
}

class ErrorRepository extends FakeRepository {
  bool fail = true;
  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async {
    if (fail) throw const NetworkFailure();
    return super.getProducts(query: query, category: category, skip: skip);
  }
}

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
  }) async => ProductPage(items: [phone], total: 1);
}

void main() {
  testWidgets('shows an explicit empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(EmptyRepository()),
        ],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se encontraron productos'), findsOneWidget);
  });

  testWidgets('shows a typed list error and recovers with retry', (
    tester,
  ) async {
    final repository = ErrorRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(const NetworkFailure().message), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Phone'), findsOneWidget);
  });

  testWidgets('theme and cart remain available on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(FakeRepository()),
        ],
        child: const MaterialApp(home: ProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Cambiar tema'), findsOneWidget);
    expect(find.byTooltip('Carrito (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
