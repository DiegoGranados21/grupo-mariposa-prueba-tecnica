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
      child: Tooltip(
        message: 'Carrito ($count)',
        child: InkResponse(
          onTap: isCurrentPage ? null : () => context.push('/cart'),
          radius: 28,
          child: SizedBox(
            width: 56,
            height: kToolbarHeight,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white, size: 30),
                if (count > 0)
                  Positioned(
                    top: 7,
                    right: 5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB91C1C),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
