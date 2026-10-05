# Prueba técnica - Front-end Jr (Flutter + Angular)

Este repositorio contiene dos implementaciones pequeñas que consumen DummyJSON:

- `flutter_app/`: mini catálogo de productos con búsqueda, detalle y carrito local.
- `angular_app/`: panel de pedidos que muestra los carritos disponibles.

## Decisiones de arquitectura

### Flutter

La app está organizada por funcionalidad y por capas. `data` conoce HTTP y convierte JSON a entidades; `domain` contiene entidades inmutables y el contrato del repositorio; `presentation` contiene providers y widgets. Así la UI nunca depende de `http` y el repositorio se puede reemplazar por uno falso en pruebas.

Se usó Riverpod sin generación de código para que la solución sea fácil de seguir. `ProductsNotifier` es un `AsyncNotifier` para los estados de red; `CartNotifier` es un `Notifier` para el estado local y síncrono del carrito. Los cambios del carrito crean nuevas listas/objetos en lugar de mutarlos. Los DTO se hacen manualmente porque son pocos y evita añadir una fase de generación de código.

La búsqueda espera 400 ms antes de consultar. La pantalla de detalle usa una familia de providers indexada por `id`. `go_router` mantiene las rutas declaradas. También se incluyó un provider de tema, como mejora pequeña y aislada.

### Angular

`OrdersService` encapsula `HttpClient` y devuelve datos tipados. `OrdersPageComponent` es el contenedor: carga, filtra y navega. `OrderCardComponent` solo recibe un pedido y emite la intención de verlo. El filtro combina `FormControl` con Signals y la plantilla usa `@if` / `@for`. El `async` pipe se encarga de la suscripción HTTP y evita fugas de memoria.

Un paralelo útil: el servicio de Angular cumple un papel parecido al repositorio de Flutter; un componente presentacional se parece a un widget sin estado; y un `Signal` representa estado reactivo de forma parecida a un provider simple.

## Ejecutar

### Flutter

Requiere Flutter estable (Dart 3.3 o superior):

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

### Angular

Requiere Node 20+ y npm:

```bash
cd angular_app
npm install
npm test -- --watch=false
npm start
```

Luego abrir `http://localhost:4200`.

## Pendiente / con más tiempo

- Paginación infinita y filtro por categoría en Flutter.
- Persistencia del carrito en almacenamiento local.
- Prueba de integración Flutter y automatización CI.
- Ruta de detalle Angular con carga diferida y un pipe de moneda propio.

## Checklist de entrega

- [x] Productos: carga, error, vacío, búsqueda, detalle y carrito.
- [x] Riverpod con `AsyncNotifier`, `Notifier`, `family` y repositorio inyectable.
- [x] Tres pruebas unitarias y una prueba de widget en Flutter.
- [x] Angular standalone, strict, servicio tipado, filtro y pruebas.
- [x] Respuestas conceptuales y code review en `RESPUESTAS.md`.
