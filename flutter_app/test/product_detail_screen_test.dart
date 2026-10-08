import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/catalog_failure.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/product_detail_screen.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';

import 'products_screen_test.dart' show FakeRepository;

class RecoveringRepository extends FakeRepository {
  int calls = 0;

  @override
  Future<Product> getProduct(int id) async {
    if (++calls == 1) throw const NotFoundFailure();
    return FakeRepository.phone;
  }
}

class LongDescriptionRepository extends FakeRepository {
  @override
  Future<Product> getProduct(int id) async => Product(
    id: id,
    title: 'Long product',
    price: 10,
    rating: 4,
    thumbnail: '',
    description: List.filled(100, 'Descripción del producto.').join(' '),
  );
}

void main() {
  testWidgets('long details scroll without overflowing a small viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(
            LongDescriptionRepository(),
          ),
        ],
        child: const MaterialApp(home: ProductDetailScreen(id: 1)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Agregar al carrito'), 300);
    expect(find.text('Agregar al carrito'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('detail displays a typed error and retries the same product', (
    tester,
  ) async {
    final repository = RecoveringRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [productsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProductDetailScreen(id: 1)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(const NotFoundFailure().message), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Phone'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
