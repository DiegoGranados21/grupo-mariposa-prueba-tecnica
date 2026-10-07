import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/cart/data/cart_storage.dart';
import 'package:grupo_mariposa_catalog/features/cart/presentation/cart_provider.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';

void main() {
  const phone = Product(
    id: 1,
    title: 'Phone',
    price: 10,
    rating: 4,
    thumbnail: '',
  );
  test('adds a new product with quantity one', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(cartProvider.notifier).add(phone);
    expect(c.read(cartProvider).single.quantity, 1);
  });
  test('adds the same product by increasing its quantity', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(cartProvider.notifier)
      ..add(phone)
      ..add(phone);
    expect(c.read(cartProvider).single.quantity, 2);
  });
  test('removes product when quantity becomes zero', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(cartProvider.notifier)
      ..add(phone)
      ..changeQuantity(1, 0);
    expect(c.read(cartProvider), isEmpty);
  });
  test('loads the saved cart in a new provider container', () async {
    final storage = MemoryCartStorage();
    final first = ProviderContainer(
      overrides: [cartStorageProvider.overrideWithValue(storage)],
    );
    first.read(cartProvider.notifier).add(phone);
    first.dispose();

    final second = ProviderContainer(
      overrides: [cartStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(second.dispose);
    expect(second.read(cartProvider).single.product.title, 'Phone');
    expect(second.read(cartTotalProvider), 10);
  });
}
