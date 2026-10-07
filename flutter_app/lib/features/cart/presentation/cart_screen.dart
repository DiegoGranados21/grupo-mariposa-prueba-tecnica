import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'cart_app_bar_action.dart';
import 'cart_provider.dart';

final _currencyFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
);

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
                                '${_currencyFormat.format(item.product.price)} c/u\n'
                                'Subtotal: ${_currencyFormat.format(item.subtotal)}',
                              ),
                              isThreeLine: true,
                            ),
                            _QuantityControls(
                              inputKey: ValueKey('quantity-${item.product.id}'),
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
                              onQuantityChanged: (quantity) => ref
                                  .read(cartProvider.notifier)
                                  .changeQuantity(item.product.id, quantity),
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
                          _currencyFormat.format(total),
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

class _QuantityControls extends StatefulWidget {
  const _QuantityControls({
    required this.inputKey,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final Key inputKey;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode()..addListener(_restoreInvalidQuantity);
  }

  @override
  void didUpdateWidget(covariant _QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    final displayedQuantity = int.tryParse(_controller.text);
    if (displayedQuantity != widget.quantity) {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_restoreInvalidQuantity)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _restoreInvalidQuantity() {
    final quantity = int.tryParse(_controller.text);
    if (!_focusNode.hasFocus && (quantity == null || quantity <= 0)) {
      _controller.text = '${widget.quantity}';
    }
  }

  void _updateQuantity(String value) {
    final quantity = int.tryParse(value);
    if (quantity != null && quantity > 0 && quantity != widget.quantity) {
      widget.onQuantityChanged(quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          tooltip: 'Restar una unidad',
          onPressed: widget.onDecrease,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 96,
          child: TextField(
            key: widget.inputKey,
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              labelText: 'Cantidad',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onTap: () => _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            ),
            onChanged: _updateQuantity,
            onSubmitted: (value) {
              final quantity = int.tryParse(value);
              if (quantity == null || quantity <= 0) {
                _controller.text = '${widget.quantity}';
              }
            },
          ),
        ),
        IconButton(
          tooltip: 'Sumar una unidad',
          onPressed: widget.onIncrease,
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          tooltip: 'Eliminar producto del carrito',
          onPressed: widget.onRemove,
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
