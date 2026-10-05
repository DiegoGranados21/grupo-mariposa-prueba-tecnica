import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/cart_provider.dart';
import 'products_providers.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (item) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.thumbnail.isNotEmpty)
                Center(child: Image.network(item.thumbnail, height: 180)),
              const SizedBox(height: 16),
              Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
              Text('\$${item.price.toStringAsFixed(2)} · ★ ${item.rating}'),
              const SizedBox(height: 16),
              Text(item.description),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ref.read(cartProvider.notifier).add(item),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar al carrito'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
