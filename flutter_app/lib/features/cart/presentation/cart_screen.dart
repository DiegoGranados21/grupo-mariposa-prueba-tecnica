import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_app_bar_action.dart';
import 'cart_provider.dart';
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider); final total = ref.watch(cartTotalProvider);
    return Scaffold(appBar: AppBar(title: const Text('Carrito'), actions: const [CartAppBarAction(isCurrentPage: true)]), body: items.isEmpty ? const Center(child: Text('El carrito está vacío')) : Column(children: [Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (_, index) { final item = items[index]; return ListTile(title: Text(item.product.title), subtitle: Text('\$${item.subtotal.toStringAsFixed(2)}'), leading: IconButton(icon: const Icon(Icons.remove), onPressed: () => ref.read(cartProvider.notifier).changeQuantity(item.product.id, item.quantity - 1)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('${item.quantity}'), IconButton(icon: const Icon(Icons.add), onPressed: () => ref.read(cartProvider.notifier).changeQuantity(item.product.id, item.quantity + 1)), IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(cartProvider.notifier).remove(item.product.id))])); })), Padding(padding: const EdgeInsets.all(16), child: Text('Total: \$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge))]));
  }
}
