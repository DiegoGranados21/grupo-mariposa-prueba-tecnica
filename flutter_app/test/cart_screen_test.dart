import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/cart/presentation/cart_provider.dart';
import 'package:grupo_mariposa_catalog/features/cart/presentation/cart_screen.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';

void main() {
  const product = Product(
    id: 1,
    title: 'Producto de prueba',
    price: 2499.99,
    rating: 4.5,
    thumbnail: '',
  );

  testWidgets('allows typing a quantity and formats large totals', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(product);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CartScreen()),
      ),
    );

    await tester.enterText(find.byKey(const ValueKey('quantity-1')), '50');
    await tester.pump();

    expect(container.read(cartProvider).single.quantity, 50);
    expect(find.text(r'$124,999.50'), findsOneWidget);

    await tester.tap(find.byTooltip('Sumar una unidad'));
    await tester.pump();

    expect(find.widgetWithText(TextField, '51'), findsOneWidget);
    expect(find.text(r'$127,499.49'), findsOneWidget);
  });
}
