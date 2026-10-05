import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme_provider.dart';
import '../../cart/presentation/cart_app_bar_action.dart';
import '../../cart/presentation/cart_provider.dart';
import 'products_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final isCompact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCompact ? 'Catálogo' : 'Mini Catálogo'),
        actions: [
          const CartAppBarAction(),
          if (!isCompact)
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
            child: TextField(
              onChanged: ref.read(productsProvider.notifier).search,
              decoration: const InputDecoration(
                labelText: 'Buscar productos',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: FilledButton(
                  onPressed: ref.read(productsProvider.notifier).retry,
                  child: const Text('Reintentar'),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron productos'));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final product = items[index];
                    return ListTile(
                      leading: product.thumbnail.isEmpty
                          ? const Icon(Icons.image_not_supported)
                          : Image.network(
                              product.thumbnail,
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
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () =>
                            ref.read(cartProvider.notifier).add(product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
