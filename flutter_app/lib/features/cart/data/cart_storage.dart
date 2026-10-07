import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cart_item.dart';

abstract interface class CartStorage {
  List<CartItem> load();
  Future<void> save(List<CartItem> items);
}

class MemoryCartStorage implements CartStorage {
  List<CartItem> _items = [];

  @override
  List<CartItem> load() => List.unmodifiable(_items);

  @override
  Future<void> save(List<CartItem> items) async {
    _items = List.unmodifiable(items);
  }
}

class PreferencesCartStorage implements CartStorage {
  PreferencesCartStorage(this._preferences, {this.storageKey = key});

  static const key = 'catalog_cart_v1';
  final SharedPreferencesWithCache _preferences;
  final String storageKey;
  Future<void> _pending = Future.value();

  @override
  List<CartItem> load() {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .where((item) => item.quantity > 0)
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<void> save(List<CartItem> items) {
    final raw = jsonEncode(items.map((item) => item.toJson()).toList());
    _pending = _pending
        .catchError((Object _) {})
        .then((_) => _preferences.setString(storageKey, raw));
    return _pending;
  }
}
