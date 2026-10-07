import 'product.dart';
import 'product_page.dart';

abstract interface class ProductsRepository {
  Future<ProductPage> getProducts({
    String query = '',
    String category = '',
    int skip = 0,
  });
  Future<List<String>> getCategories();
  Future<Product> getProduct(int id);
}
