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

    final label = count == 0
        ? 'Abrir carrito vacío'
        : 'Abrir carrito con $count ${count == 1 ? 'artículo' : 'artículos'}';

    return Semantics(
      button: true,
      enabled: !isCurrentPage,
      label: label,
      child: IconButton(
        tooltip: 'Carrito ($count)',
        color: Colors.white,
        disabledColor: Colors.white,
        onPressed: isCurrentPage ? null : () => context.push('/cart'),
        icon: Badge.count(
          count: count,
          isLabelVisible: count > 0,
          backgroundColor: const Color(0xFFB91C1C),
          textColor: Colors.white,
          child: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
    );
  }
}
