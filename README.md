# Prueba técnica - Front-end Jr (Flutter + Angular)

Este repositorio contiene dos implementaciones pequeñas que consumen DummyJSON:

- `flutter_app/`: mini catálogo de productos con búsqueda, detalle y carrito local.
- `angular_app/`: panel de pedidos que muestra los carritos disponibles.

## Decisiones de arquitectura

### Flutter

La app está organizada por funcionalidad y por capas. `data` conoce HTTP y convierte JSON a entidades; `domain` contiene entidades inmutables y el contrato del repositorio; `presentation` contiene providers y widgets. Así la UI nunca depende de `http` y el repositorio se puede reemplazar por uno falso en pruebas.

`ProductsNotifier` es un `AsyncNotifier` para los estados de red; `CartNotifier` es un `Notifier` para el estado local y síncrono del carrito. Los cambios del carrito crean nuevas listas/objetos en lugar de mutarlos. `CatalogFilters` reúne búsqueda y categoría en un único estado. El JSON de `Product` usa `json_serializable`; categorías y detalle usan `riverpod_generator` con `@Riverpod`. Los archivos generados están incluidos para compilar al clonar, sin tener que ejecutar el generador.

La búsqueda espera 400 ms antes de consultar. La lista carga 20 productos por página y solicita la siguiente al acercarse al final. Búsqueda y categoría se combinan sin borrar el otro filtro. Como DummyJSON separa ambos endpoints, al combinarlos el repositorio solicita la categoría completa con `limit=0`, filtra título/descripción y pagina los resultados en memoria. No filtra solo la primera página, lo que perdería coincidencias. Esta decisión es razonable para el catálogo de demostración; con más volumen correspondería un endpoint que aplique ambos filtros en el servidor.

Una actualización conserva los datos anteriores y muestra progreso; si falla, conserva la lista y ofrece reintentar. Un contador de generación impide que respuestas antiguas reemplacen una búsqueda posterior. La pantalla de detalle usa una familia de providers indexada por `id`; `go_router` mantiene las rutas declaradas. Los errores de conexión, servidor, JSON, 404 y timeout se distinguen con tipos propios. Las peticiones tienen un límite de 15 segundos y los reintentos son explícitos desde la UI.

`productsProvider` conserva intencionalmente lista y filtros al volver del detalle o carrito. El detalle generado usa `autoDispose`, porque cada identificador es una consulta temporal. Se mantiene `standalone: true` en Angular para que el requisito sea visible, aunque Angular 19 ya lo asume por defecto.

El carrito se guarda en `shared_preferences` y se recupera al iniciar. El acceso al almacenamiento está detrás de `CartStorage`, que permite usar una implementación en memoria en pruebas. El tema claro/oscuro y los controles accesibles son mejoras independientes.

La interfaz cuida contraste en la barra de navegación, textos alternativos para imágenes relevantes, etiquetas semánticas en el carrito, confirmación al agregar productos y controles con áreas de toque cómodas. Son prácticas alineadas con WCAG, sin declarar una certificación formal.

### Angular

`OrdersService` encapsula `HttpClient` y devuelve datos tipados. `OrdersPageComponent` es el contenedor: carga, filtra y navega. `OrderCardComponent` solo recibe un pedido y emite la intención de verlo. El filtro combina `FormControl` con Signals y la plantilla usa `@if` / `@for`. El pipe propio `discountAmount` calcula el ahorro a partir del total y el total descontado; `CurrencyPipe` lo presenta como moneda. El `async` pipe se encarga de la suscripción HTTP y evita fugas de memoria.

Un paralelo útil: el servicio de Angular cumple un papel parecido al repositorio de Flutter; un componente presentacional se parece a un widget sin estado; y un `Signal` representa estado reactivo de forma parecida a un provider simple. La ruta `/orders/:id` se carga de forma diferida para consultar el detalle de un pedido. La URL base está en `src/environments/environment.ts`. Hay una página para rutas inexistentes, foco visible de teclado, mensajes de estado accesibles y botones de detalle identificados por pedido.

## Ejecutar

### Flutter

Versión verificada y fijada en CI: **Flutter 3.47.6 / Dart 3.13.5**. `pubspec.yaml` requiere Dart >=3.12.0 y el lockfile fija las dependencias. Se utiliza Riverpod 3, permitido por el enunciado, con versiones compatibles de su generador. Requiere una plataforma configurada y conexión a Internet para DummyJSON:

```bash
cd flutter_app
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run -d chrome
```

Para una vista web local sin lanzar Chrome: `flutter run -d web-server --web-port 4300`; abrir `http://127.0.0.1:4300` mientras ese proceso siga activo. Para escritorio: `flutter run -d windows` (requiere Visual Studio con herramientas C++).

La prueba de integración ejecuta búsqueda → detalle → agregar al carrito y verifica persistencia real con una clave de prueba independiente. En Windows:

```bash
flutter test integration_test/catalog_flow_test.dart -d windows
```

Si cambias `Product` o los providers anotados, ejecuta `dart run build_runner build`, después `dart format .` y confirma los archivos `.g.dart` actualizados.

En Android, el identificador es `dev.diegogranados.mariposacatalog` y el manifiesto principal permite Internet. Para evaluación puede generarse `flutter build apk --debug`, con Android SDK configurado. No se incluyen claves privadas ni se presenta un APK de producción firmado: una distribución release requiere configurar una firma propia, no reutilizar la de debug.

En este equipo `flutter doctor` informa que faltan licencias Android por aceptar. No se validó un APK en esta revisión; la ejecución y las pruebas de integración se verifican en Windows/web. El propietario debe revisar y aceptar las licencias con `flutter doctor --android-licenses` antes de compilar Android.

### Angular

Versión local verificada: **Node 22.17.0**, npm 10.9.2 y Angular 19.2. Requiere Chrome para las pruebas y conexión a Internet para DummyJSON:

```bash
cd angular_app
npm ci
npm run format:check
npm run lint
npm run build
npm test
npm start
```

Luego abrir `http://localhost:4200`. `npm test` ejecuta ChromeHeadless y genera cobertura en `angular_app/coverage/`. CI la adjunta como artefacto. `npm run format` aplica Prettier cuando se modifica el código.

Estos enlaces locales solo funcionan en el equipo que ejecuta el servidor. Un entrevistador debe clonar el repositorio y seguir los comandos anteriores; no hay una demo pública desplegada. Las pruebas usan respuestas controladas para ser reproducibles. La vista real depende de la disponibilidad y los datos actuales de DummyJSON; no garantiza un inventario idéntico en el futuro.

## Decisiones y límites

- El carrito es local al dispositivo. No hay servidor, cuenta ni proceso de pago.
- La paginación se reinicia al cambiar búsqueda o categoría. La consulta conserva el debounce de 400 ms.
- La prueba de integración usa un repositorio falso para ser estable; la persistencia sí utiliza el plugin real en Windows.
- `shared_preferences` es apropiado para datos locales no críticos. No sustituye una base de datos transaccional.
- La accesibilidad incorpora prácticas útiles, sin afirmar una auditoría WCAG completa.
- Los importes usan `double`, suficiente para este ejercicio sin cobros. En producción usaría centavos enteros o un decimal y reglas explícitas de redondeo.
- `npm audit` reporta avisos en dependencias de Angular 19. No se ejecutó una actualización forzada a otra versión mayor durante esta mejora. Antes de un despliegue de producción revisaría cada aviso y migraría Angular a una versión soportada, con sus pruebas. La prueba técnica no debe interpretarse como una certificación de seguridad.
- La revisión de las recomendaciones y sus límites está en `REVISION_MEJORAS.md`.

## Checklist de entrega

Verificación local (8 de octubre de 2026): `flutter analyze` sin incidencias y **18 pruebas Flutter** (15 unitarias y 3 de widgets). Angular: formato, lint y build correctos, **9 pruebas en 5 archivos spec**. La integración Windows se ejecuta por separado (2 casos). La cobertura Angular reportada corresponde a los archivos instrumentados por esa ejecución, no a una certificación de cobertura total del sistema.

- [x] Productos: carga, error, vacío, búsqueda, detalle y carrito.
- [x] Riverpod con `AsyncNotifier`, `Notifier`, `family` y repositorio inyectable.
- [x] Pruebas Flutter de modelo, repositorio, providers, carrito y widgets; regresiones de debounce, respuestas obsoletas, reintentos, paginación y filtros combinados.
- [x] Angular standalone, strict, servicio tipado, filtro y pruebas.
- [x] Respuestas conceptuales y code review en `RESPUESTAS.md`.
- [x] Ruta Angular de detalle con carga diferida y verificación continua en GitHub Actions.
- [x] Flutter: paginación, categorías, carrito persistente, errores tipados y prueba de integración.
- [x] Flutter: serialización generada de `Product`, providers con `riverpod_generator` y tema claro/oscuro.
- [x] Angular: pipe propio para el ahorro, Signals, control flow moderno y `OnPush`.
