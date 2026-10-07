import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grupo_mariposa_catalog/app.dart';
import 'package:grupo_mariposa_catalog/features/cart/data/cart_storage.dart';
import 'package:grupo_mariposa_catalog/features/cart/domain/cart_item.dart';
import 'package:grupo_mariposa_catalog/features/cart/presentation/cart_provider.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/product_page.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/presentation/products_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoRepository implements ProductsRepository {
  static const product = Product(
    id: 1,
    title: 'Producto de prueba',
    price: 25,
    rating: 4.5,
    thumbnail: '',
  );

  @override
  Future<List<String>> getCategories() async => ['beauty'];

  @override
  Future<Product> getProduct(int id) async => product;

  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async => const ProductPage(items: [product], total: 1);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('catalog to detail to cart flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productsRepositoryProvider.overrideWithValue(DemoRepository()),
          cartStorageProvider.overrideWithValue(MemoryCartStorage()),
        ],
        child: const CatalogApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Producto de prueba'));
    await tester.pumpAndSettle();
    expect(find.text('Agregar al carrito'), findsOneWidget);

    await tester.tap(find.text('Agregar al carrito'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Carrito (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Carrito'), findsOneWidget);
    expect(find.text('\$25.00'), findsOneWidget);
  });

  testWidgets('persists the cart across storage instances', (tester) async {
    const testKey = 'catalog_cart_integration_test_v1';
    final firstPreferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: {testKey},
      ),
    );
    try {
      final first = PreferencesCartStorage(
        firstPreferences,
        storageKey: testKey,
      );
      await first.save(const [
        CartItem(product: DemoRepository.product, quantity: 2),
      ]);

      final secondPreferences = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {testKey},
        ),
      );
      final second = PreferencesCartStorage(
        secondPreferences,
        storageKey: testKey,
      );
      expect(second.load().single.quantity, 2);
      expect(second.load().single.product.title, 'Producto de prueba');
    } finally {
      await firstPreferences.remove(testKey);
    }
  });
}
