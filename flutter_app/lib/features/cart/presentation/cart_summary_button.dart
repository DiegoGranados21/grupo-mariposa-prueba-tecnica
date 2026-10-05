import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'cart_provider.dart';
class CartSummaryButton extends ConsumerWidget {
  const CartSummaryButton({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return FloatingActionButton.extended(onPressed: () => context.go('/cart'), icon: const Icon(Icons.shopping_cart), label: Text('Carrito ($count)'));
  }
}
