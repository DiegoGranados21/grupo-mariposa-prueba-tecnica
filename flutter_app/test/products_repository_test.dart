import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grupo_mariposa_catalog/features/products/data/http_products_repository.dart';
import 'package:grupo_mariposa_catalog/features/products/domain/catalog_failure.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'combines search and category before paginating the matching products',
    () async {
      Uri? requested;
      final repository = HttpProductsRepository(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(
            jsonEncode({
              'products': [
                for (var id = 1; id <= 25; id++)
                  {
                    'id': id,
                    'title': 'Phone $id',
                    'price': 10,
                    'rating': 4,
                    'thumbnail': '',
                  },
                {
                  'id': 26,
                  'title': 'Tablet',
                  'price': 10,
                  'rating': 4,
                  'thumbnail': '',
                },
              ],
              'total': 26,
            }),
            200,
          );
        }),
      );
      addTearDown(repository.close);
      final page = await repository.getProducts(
        query: 'PHONE',
        category: 'smartphones',
        skip: 20,
      );
      expect(requested!.path, '/products/category/smartphones');
      expect(requested!.queryParameters['limit'], '0');
      expect(page.total, 25);
      expect(page.items.map((product) => product.id), [21, 22, 23, 24, 25]);
    },
  );

  test('distinguishes a missing product from an unavailable server', () async {
    final repository = HttpProductsRepository(
      client: MockClient((_) async => http.Response('{}', 404)),
    );
    addTearDown(repository.close);
    expect(repository.getProduct(9999), throwsA(isA<NotFoundFailure>()));
  });

  test('ends a hung request with a typed timeout', () async {
    final repository = HttpProductsRepository(
      requestTimeout: const Duration(milliseconds: 10),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    addTearDown(repository.close);
    await expectLater(repository.getProducts(), throwsA(isA<TimeoutFailure>()));
  });

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
