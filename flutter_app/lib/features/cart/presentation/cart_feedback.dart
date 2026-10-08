import 'package:flutter/material.dart';

void showCartFeedback(BuildContext context, String title) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$title agregado al carrito')));
}
