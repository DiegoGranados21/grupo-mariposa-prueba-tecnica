import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/core/theme_provider.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';

void main() {
  test('ProductPage protects its collection from external mutation', () {
    final products = <Product>[];
    final page = ProductPage(items: products, total: 0);
    expect(() => page.items.clear(), throwsUnsupportedError);
    expect(identical(page.items, products), isFalse);
  });
  test('Product accepts integer prices and survives a JSON round trip', () {
    final product = Product.fromJson({
      'id': 1,
      'title': 'Phone',
      'price': 10,
      'rating': 4.5,
    });
    expect(product.price, 10.0);
    expect(product.thumbnail, isEmpty);
    expect(Product.fromJson(product.toJson()).rating, 4.5);
  });

  test('theme switches between dark and light through its notifier', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
