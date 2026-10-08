import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/cart_provider.dart';
import '../../cart/presentation/cart_app_bar_action.dart';
import '../../cart/presentation/cart_feedback.dart';
import 'products_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: const [CartAppBarAction()],
      ),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$error'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(productDetailProvider(id)),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (item) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.thumbnail.isNotEmpty)
                  Center(
                    child: Image.network(
                      item.thumbnail,
                      height: 180,
                      semanticLabel: 'Imagen de ${item.title}',
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('\$${item.price.toStringAsFixed(2)} · ★ ${item.rating}'),
                const SizedBox(height: 16),
                Text(item.description),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      ref.read(cartProvider.notifier).add(item);
                      showCartFeedback(context, item.title);
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Agregar al carrito'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
