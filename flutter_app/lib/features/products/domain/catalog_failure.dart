sealed class CatalogFailure implements Exception {
  const CatalogFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends CatalogFailure {
  const NetworkFailure()
    : super('No hay conexión. Revisa Internet y reintenta.');
}

class ServerFailure extends CatalogFailure {
  const ServerFailure() : super('El catálogo no está disponible. Reintenta.');
}

class DataFailure extends CatalogFailure {
  const DataFailure() : super('La respuesta del catálogo no es válida.');
}

class NotFoundFailure extends CatalogFailure {
  const NotFoundFailure() : super('No se encontró el producto solicitado.');
}

class TimeoutFailure extends CatalogFailure {
  const TimeoutFailure()
    : super('La consulta tardó demasiado. Intenta de nuevo.');
}
