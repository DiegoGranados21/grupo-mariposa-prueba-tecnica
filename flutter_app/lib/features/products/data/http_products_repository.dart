import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/product.dart';
import '../domain/products_repository.dart';

class HttpProductsRepository implements ProductsRepository {
  HttpProductsRepository({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _baseUrl = 'https://dummyjson.com';
  @override
  Future<List<Product>> getProducts({String query = ''}) async {
    final path = query.trim().isEmpty ? '/products?limit=20&skip=0' : '/products/search?q=${Uri.encodeQueryComponent(query.trim())}';
    final response = await _client.get(Uri.parse('$_baseUrl$path'));
    if (response.statusCode != 200) throw Exception('No se pudieron cargar los productos.');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['products'] as List<dynamic>).map((item) => Product.fromJson(item as Map<String, dynamic>)).toList(growable: false);
  }
  @override
  Future<Product> getProduct(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/products/$id'));
    if (response.statusCode != 200) throw Exception('No se pudo cargar el producto.');
    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
