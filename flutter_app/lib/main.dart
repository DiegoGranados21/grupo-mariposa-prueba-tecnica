import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/cart/data/cart_storage.dart';
import 'features/cart/presentation/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {PreferencesCartStorage.key},
    ),
  );
  runApp(
    ProviderScope(
      overrides: [
        cartStorageProvider.overrideWithValue(
          PreferencesCartStorage(preferences),
        ),
      ],
      child: const CatalogApp(),
    ),
  );
}
