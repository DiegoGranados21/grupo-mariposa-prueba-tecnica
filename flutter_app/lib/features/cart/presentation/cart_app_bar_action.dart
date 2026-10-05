import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cart_provider.dart';

class CartAppBarAction extends ConsumerWidget {
  const CartAppBarAction({super.key, this.isCurrentPage = false});

  final bool isCurrentPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);

    return IconButton(
      tooltip: 'Ver carrito',
      onPressed: isCurrentPage ? null : () => context.push('/cart'),
      icon: Badge.count(
        count: count,
        isLabelVisible: count > 0,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
