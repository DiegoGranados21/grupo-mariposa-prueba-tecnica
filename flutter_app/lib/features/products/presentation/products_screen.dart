import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_provider.dart';
import '../../cart/presentation/cart_app_bar_action.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../cart/presentation/cart_feedback.dart';
import '../domain/catalog_failure.dart';
import '../domain/product_page.dart';
import 'products_providers.dart';
import 'catalog_filters.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(catalogFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final filters = ref.watch(catalogFiltersProvider);
    ref.listen(catalogFiltersProvider, (_, next) {
      if (_searchController.text != next.query) {
        _searchController.text = next.query;
      }
    });
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCompact ? 'Catálogo' : 'Mini Catálogo'),
        actions: [
          const CartAppBarAction(),
          IconButton(
            tooltip: 'Cambiar tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: const Icon(Icons.brightness_6),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (query) =>
                      ref.read(productsProvider.notifier).search(query),
                  decoration: const InputDecoration(
                    labelText: 'Buscar productos',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                categories.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => TextButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: const Text('Reintentar categorías'),
                  ),
                  data: (values) => DropdownButtonFormField<String>(
                    key: ValueKey(filters.category),
                    initialValue: filters.category,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Todas')),
                      for (final value in values)
                        DropdownMenuItem(value: value, child: Text(value)),
                    ],
                    onChanged: (category) {
                      if (category == null) return;
                      ref
                          .read(productsProvider.notifier)
                          .selectCategory(category);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (products.isLoading && products.hasValue)
            const LinearProgressIndicator(
              semanticsLabel: 'Actualizando productos',
            ),
          if (products.hasError && products.hasValue)
            MaterialBanner(
              content: Text('${products.error}'),
              actions: [
                TextButton(
                  onPressed: () => ref.read(productsProvider.notifier).retry(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          Expanded(
            child: products.when(
              skipLoadingOnReload: true,
              skipError: products.hasValue,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      error is CatalogFailure
                          ? error.message
                          : 'No se pudieron cargar los productos.',
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          ref.read(productsProvider.notifier).retry(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (page) => _ProductList(page: page),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  const _ProductList({required this.page});

  final ProductPage page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (page.items.isEmpty) {
      return const Center(child: Text('No se encontraron productos'));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 250 &&
            !ref.read(productsProvider).isLoading &&
            !ref.read(productsProvider).hasError &&
            page.hasMore &&
            !page.loadingMore &&
            !page.loadMoreError) {
          scheduleMicrotask(
            () => ref.read(productsProvider.notifier).loadMore(),
          );
        }
        return false;
      },
      child: ListView.builder(
        itemCount: page.items.length + (page.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == page.items.length) {
            if (page.loadMoreError) {
              return Center(
                child: TextButton(
                  onPressed: () =>
                      ref.read(productsProvider.notifier).retryLoadMore(),
                  child: const Text('Reintentar más productos'),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: page.loadingMore
                    ? const CircularProgressIndicator()
                    : const Text('Desliza para ver más productos'),
              ),
            );
          }
          final product = page.items[index];
          return ListTile(
            leading: product.thumbnail.isEmpty
                ? const Icon(Icons.image_not_supported)
                : Image.network(
                    product.thumbnail,
                    semanticLabel: 'Imagen de ${product.title}',
                    width: 56,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                  ),
            title: Text(product.title),
            subtitle: Text(
              '\$${product.price.toStringAsFixed(2)} · '
              '★ ${product.rating.toStringAsFixed(1)}',
            ),
            onTap: () => context.push('/products/${product.id}'),
            trailing: IconButton(
              tooltip: 'Agregar ${product.title} al carrito',
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                ref.read(cartProvider.notifier).add(product);
                showCartFeedback(context, product.title);
              },
            ),
          );
        },
      ),
    );
  }
}
