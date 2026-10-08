import 'package:flutter_riverpod/flutter_riverpod.dart';

class CatalogFilters {
  const CatalogFilters({this.query = '', this.category = ''});

  final String query;
  final String category;
}

final catalogFiltersProvider =
    NotifierProvider<CatalogFiltersNotifier, CatalogFilters>(
      CatalogFiltersNotifier.new,
    );

class CatalogFiltersNotifier extends Notifier<CatalogFilters> {
  @override
  CatalogFilters build() => const CatalogFilters();

  void search(String query) =>
      state = CatalogFilters(query: query, category: state.category);

  void selectCategory(String category) =>
      state = CatalogFilters(query: state.query, category: category);
}
