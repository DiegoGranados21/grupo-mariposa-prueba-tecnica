import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_app_bar_action.dart';
import 'cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: const [CartAppBarAction(isCurrentPage: true)],
      ),
      body: items.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: _ProductThumbnail(
                                imageUrl: item.product.thumbnail,
                                title: item.product.title,
                              ),
                              title: Text(item.product.title),
                              subtitle: Text(
                                '\$${item.product.price.toStringAsFixed(2)} c/u\n'
                                'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                              ),
                              isThreeLine: true,
                            ),
                            _QuantityControls(
                              quantity: item.quantity,
                              onDecrease: () => ref
                                  .read(cartProvider.notifier)
                                  .changeQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  ),
                              onIncrease: () => ref
                                  .read(cartProvider.notifier)
                                  .changeQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  ),
                              onRemove: () => ref
                                  .read(cartProvider.notifier)
                                  .remove(item.product.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const SizedBox(
        width: 56,
        height: 56,
        child: Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        semanticLabel: 'Imagen de $title',
        errorBuilder: (_, __, ___) => const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Restar una unidad',
          onPressed: onDecrease,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Semantics(
          label: 'Cantidad: $quantity',
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Sumar una unidad',
          onPressed: onIncrease,
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          tooltip: 'Eliminar producto del carrito',
          onPressed: onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
