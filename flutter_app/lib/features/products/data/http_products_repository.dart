import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/catalog_failure.dart';
import '../domain/product.dart';
import '../domain/product_page.dart';
import '../domain/products_repository.dart';

class HttpProductsRepository implements ProductsRepository {
  HttpProductsRepository({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;
  static const _baseUrl = 'https://dummyjson.com';
  static const pageSize = 20;

  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) throw const ServerFailure();
      return jsonDecode(response.body);
    } on CatalogFailure {
      rethrow;
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const DataFailure();
    } on Exception {
      throw const NetworkFailure();
    }
  }

  @override
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  }) async {
    final path = category.isNotEmpty
        ? '/products/category/${Uri.encodeComponent(category)}'
        : query.trim().isNotEmpty
        ? '/products/search'
        : '/products';
    final parameters = <String, String>{
      'limit': '$pageSize',
      'skip': '$skip',
      if (category.isEmpty && query.trim().isNotEmpty) 'q': query.trim(),
    };
    final json = await _get(
      Uri.parse('$_baseUrl$path').replace(queryParameters: parameters),
    );
    try {
      final data = json as Map<String, dynamic>;
      return ProductPage(
        items: (data['products'] as List<dynamic>)
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
        total: data['total'] as int,
      );
    } on Object {
      throw const DataFailure();
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final json = await _get(Uri.parse('$_baseUrl/products/category-list'));
    try {
      return (json as List<dynamic>).cast<String>();
    } on Object {
      throw const DataFailure();
    }
  }

  @override
  Future<Product> getProduct(int id) async {
    final json = await _get(Uri.parse('$_baseUrl/products/$id'));
    try {
      return Product.fromJson(json as Map<String, dynamic>);
    } on Object {
      throw const DataFailure();
    }
  }
}
