import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/domain/product.dart';
import '../data/cart_storage.dart';
import '../domain/cart_item.dart';

final cartStorageProvider = Provider<CartStorage>((ref) => MemoryCartStorage());

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() =>
      List.unmodifiable(ref.read(cartStorageProvider).load());

  void _setItems(List<CartItem> items) {
    state = List.unmodifiable(items);
    unawaited(ref.read(cartStorageProvider).save(items));
  }

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    _setItems(
      index == -1
          ? [...state, CartItem(product: product, quantity: 1)]
          : [
              for (var i = 0; i < state.length; i++)
                if (i == index)
                  state[i].copyWith(quantity: state[i].quantity + 1)
                else
                  state[i],
            ],
    );
  }

  void changeQuantity(int productId, int quantity) {
    _setItems(
      quantity <= 0
          ? [
              for (final item in state)
                if (item.product.id != productId) item,
            ]
          : [
              for (final item in state)
                if (item.product.id == productId)
                  item.copyWith(quantity: quantity)
                else
                  item,
            ],
    );
  }

  void remove(int productId) {
    _setItems([
      for (final item in state)
        if (item.product.id != productId) item,
    ]);
  }
}

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity),
);

final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.subtotal),
);
