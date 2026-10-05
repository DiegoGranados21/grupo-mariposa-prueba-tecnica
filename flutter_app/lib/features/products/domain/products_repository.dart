import 'product.dart';

abstract interface class ProductsRepository {
  Future<List<Product>> getProducts({String query = ''});
  Future<Product> getProduct(int id);
}
