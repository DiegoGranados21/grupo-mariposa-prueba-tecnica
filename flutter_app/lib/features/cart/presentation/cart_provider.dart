import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';
import '../../products/domain/product.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
class CartNotifier extends Notifier<List<CartItem>> {
  @override List<CartItem> build() => const [];
  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    state = index == -1 ? [...state, CartItem(product: product, quantity: 1)] : [for (var i = 0; i < state.length; i++) if (i == index) state[i].copyWith(quantity: state[i].quantity + 1) else state[i]];
  }
  void changeQuantity(int productId, int quantity) => state = quantity <= 0 ? [for (final item in state) if (item.product.id != productId) item] : [for (final item in state) if (item.product.id == productId) item.copyWith(quantity: quantity) else item];
  void remove(int productId) => state = [for (final item in state) if (item.product.id != productId) item];
}
final cartCountProvider = Provider<int>((ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity));
final cartTotalProvider = Provider<double>((ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.subtotal));
