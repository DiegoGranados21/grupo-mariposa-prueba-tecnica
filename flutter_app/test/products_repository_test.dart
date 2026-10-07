import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/data/http_products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/catalog_failure.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('uses limit and skip for category pagination', () async {
    Uri? requested;
    final repository = HttpProductsRepository(
      client: MockClient((request) async {
        requested = request.url;
        return http.Response(jsonEncode({'products': [], 'total': 35}), 200);
      }),
    );

    final page = await repository.getProducts(category: 'beauty', skip: 20);
    expect(requested!.path, '/products/category/beauty');
    expect(requested!.queryParameters, {'limit': '20', 'skip': '20'});
    expect(page.total, 35);
  });

  test('returns a typed failure for an unavailable server', () async {
    final repository = HttpProductsRepository(
      client: MockClient((_) async => http.Response('', 503)),
    );
    expect(repository.getProducts(), throwsA(isA<ServerFailure>()));
  });
}
