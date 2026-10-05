import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme_provider.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/products/presentation/product_detail_screen.dart';
import 'features/products/presentation/products_screen.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const ProductsScreen()),
        GoRoute(path: '/products/:id', builder: (_, state) => ProductDetailScreen(id: int.parse(state.pathParameters['id']!))),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
      ],
    ));

class CatalogApp extends ConsumerWidget {
  const CatalogApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Mini Catálogo',
        debugShowCheckedModeBanner: false,
        themeMode: ref.watch(themeModeProvider),
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, brightness: Brightness.dark, useMaterial3: true),
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) => child ?? const SizedBox.shrink(),
      );
}
