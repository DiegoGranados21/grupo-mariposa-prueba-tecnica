# Prueba técnica - Front-end Jr (Flutter + Angular)

Este repositorio contiene dos implementaciones pequeñas que consumen DummyJSON:

- `flutter_app/`: mini catálogo de productos con búsqueda, detalle y carrito local.
- `angular_app/`: panel de pedidos que muestra los carritos disponibles.

## Decisiones de arquitectura

### Flutter

La app está organizada por funcionalidad y por capas. `data` conoce HTTP y convierte JSON a entidades; `domain` contiene entidades inmutables y el contrato del repositorio; `presentation` contiene providers y widgets. Así la UI nunca depende de `http` y el repositorio se puede reemplazar por uno falso en pruebas.

`ProductsNotifier` es un `AsyncNotifier` para los estados de red; `CartNotifier` es un `Notifier` para el estado local y síncrono del carrito. Los cambios del carrito crean nuevas listas/objetos en lugar de mutarlos. El JSON de `Product` usa `json_serializable`; su archivo `product.g.dart` está incluido para que la app compile al clonar el repositorio. Los providers permanecen explícitos para que su comportamiento sea fácil de seguir.

La búsqueda espera 400 ms antes de consultar. La lista carga 20 productos por página y solicita la siguiente al acercarse al final. El selector de categoría inicia una lista nueva; al buscar, se vuelve a “Todas”, ya que DummyJSON no ofrece búsqueda y categoría combinadas en un mismo endpoint. Los errores de conexión, servidor y formato se distinguen con tipos propios. La pantalla de detalle usa una familia de providers indexada por `id`; `go_router` mantiene las rutas declaradas.

El carrito se guarda en `shared_preferences` y se recupera al iniciar. El acceso al almacenamiento está detrás de `CartStorage`, que permite usar una implementación en memoria en pruebas. El tema claro/oscuro y los controles accesibles son mejoras independientes.

La interfaz cuida contraste en la barra de navegación, textos alternativos para imágenes relevantes, etiquetas semánticas en el carrito y controles con áreas de toque cómodas. Son prácticas alineadas con WCAG, sin declarar una certificación formal.

### Angular

`OrdersService` encapsula `HttpClient` y devuelve datos tipados. `OrdersPageComponent` es el contenedor: carga, filtra y navega. `OrderCardComponent` solo recibe un pedido y emite la intención de verlo. El filtro combina `FormControl` con Signals y la plantilla usa `@if` / `@for`. El pipe propio `discountAmount` calcula el ahorro a partir del total y el total descontado; `CurrencyPipe` lo presenta como moneda. El `async` pipe se encarga de la suscripción HTTP y evita fugas de memoria.

Un paralelo útil: el servicio de Angular cumple un papel parecido al repositorio de Flutter; un componente presentacional se parece a un widget sin estado; y un `Signal` representa estado reactivo de forma parecida a un provider simple. La ruta `/orders/:id` se carga de forma diferida para consultar el detalle de un pedido.

## Ejecutar

### Flutter

Requiere Flutter estable reciente (Dart 3.11 o superior), una plataforma de destino configurada y conexión a Internet para DummyJSON:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter run
```

La prueba de integración ejecuta el recorrido catálogo → detalle → carrito y verifica persistencia real con una clave de prueba independiente. En Windows:

```bash
flutter test integration_test/catalog_flow_test.dart -d windows
```

Si cambias el modelo `Product`, regenera su serializador con `dart run build_runner build` y confirma el nuevo `product.g.dart`.

### Angular

Requiere Node 20+ y npm, Chrome para las pruebas, y conexión a Internet para DummyJSON:

```bash
cd angular_app
npm ci
npm run build
npm test
npm start
```

Luego abrir `http://localhost:4200`.

## Decisiones y límites

- El carrito es local al dispositivo. No hay servidor, cuenta ni proceso de pago.
- La paginación se reinicia al cambiar búsqueda o categoría. La consulta conserva el debounce de 400 ms.
- La prueba de integración usa un repositorio falso para ser estable; la persistencia sí utiliza el plugin real en Windows.
- `shared_preferences` es apropiado para datos locales no críticos. No sustituye una base de datos transaccional.
- La accesibilidad incorpora prácticas útiles, sin afirmar una auditoría WCAG completa.

## Checklist de entrega

- [x] Productos: carga, error, vacío, búsqueda, detalle y carrito.
- [x] Riverpod con `AsyncNotifier`, `Notifier`, `family` y repositorio inyectable.
- [x] Tres pruebas unitarias y una prueba de widget en Flutter.
- [x] Angular standalone, strict, servicio tipado, filtro y pruebas.
- [x] Respuestas conceptuales y code review en `RESPUESTAS.md`.
- [x] Ruta Angular de detalle con carga diferida y verificación continua en GitHub Actions.
- [x] Flutter: paginación, categorías, carrito persistente, errores tipados y prueba de integración.
- [x] Flutter: serialización generada de `Product` y tema claro/oscuro.
- [x] Angular: pipe propio para el ahorro, Signals, control flow moderno y `OnPush`.
