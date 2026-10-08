# Validación de la rúbrica

Referencia: PDF original de siete páginas, fechado 5 de octubre de 2026. Esta matriz diferencia revisión de código, pruebas automatizadas y comprobaciones de entorno. Un test con dobles de red comprueba comportamiento reproducible, no disponibilidad permanente de la API externa.

## Entregables y respuestas

| Punto | Evidencia |
| --- | --- |
| Carpetas `flutter_app/` y `angular_app/` | Proyectos independientes, con manifiestos y lockfiles versionados. |
| README raíz | Inicio rápido, versiones verificadas, arquitectura, paralelos Flutter/Angular, pendientes y mejoras futuras. |
| 20 respuestas conceptuales | `RESPUESTAS.md`, parte 1: Dart/Flutter 1-5; Riverpod 6-11; Angular 12-16; buenas prácticas 17-20. Revisión manual contra cada pregunta; ejemplos de AsyncValue y overrides incluidos. |
| Code review Flutter | Parte 4: problema, impacto y solución para petición en build, responsabilidades, tipado, lectura no reactiva, mutación, estados y ciclo de vida. Reescritura Flutter incluida. |
| Code review Angular | Parte 4: HTTP en componente, any, intervalo sin limpieza, suscripciones/estados, acoplamiento y dependencia NgFor faltante. |
| Historial real | Commits por cambios incrementales; no se reescribe el historial. |
| Repositorio público actualizado | El repositorio existe, pero los cambios de esta revisión permanecen en la rama local hasta autorización para publicar. No confundir comprobaciones locales con CI remoto aprobado. |

## Flutter: nueve requisitos indispensables

| # | Requisito | Evidencia y comprobación |
| --- | --- | --- |
| 1 | Imagen, título, precio, rating; carga/error/reintento/vacío | `products_screen.dart`; `products_screen_test.dart` verifica datos, vacío y error recuperable. Imagen con fallback; precio/rating en tarjeta. El detalle tolera contenido largo mediante scroll. |
| 2 | Debounce 400 ms | `products_providers_test.dart`: no consulta a los 399 ms, espera tras cada cambio y descarta respuestas obsoletas, incluida una carga inicial tardía. |
| 3 | Detalle por id/family | `productDetail` anotado genera family autoDispose. Widget test de error/reintento; integración abre el detalle del resultado buscado. |
| 4 | Carrito completo y contador en todas las pantallas | Pruebas de agregar, quitar, cantidad cero/50, contador, total y estado anterior inmutable; widget test del input y separadores de miles. Integración verifica contador en catálogo, detalle y carrito y navegación de regreso. |
| 5 | Riverpod 2/3, AsyncNotifier/FutureProvider y Notifier | Riverpod 3.4.3, ProductsNotifier, providers generados y CartNotifier. Revisión estática: ningún setState para negocio. Controladores de texto son estado de UI, no estado de negocio. |
| 6 | Capas y repositorio inyectado | HTTP únicamente en `data/http_products_repository.dart`. Pruebas sustituyen el contrato mediante overrides. |
| 7 | Modelos inmutables con fromJson | Product/CartItem con campos final; serialización generada y justificada en README. Prueba de JSON con precio entero y round trip. Carrito publica listas no modificables. |
| 8 | >=3 unitarias y >=1 widget | 22 unitarias y 7 de widgets, usando ProviderContainer/ProviderScope y repositorios falsos. |
| 9 | Analyze limpio | `flutter analyze` y Dart format; flutter_lints configurado y comprobaciones en CI. |

## Flutter: seis deseables y tres bonus

| Punto | Evidencia y comprobación |
| --- | --- |
| Scroll infinito | ProductsScreen solicita loadMore cerca del final; tests de acumulación, error y reintento sin duplicar. |
| Categoría combinable con búsqueda | CatalogFilters conserva ambos; repositorio filtra la categoría completa antes de paginar. Tests de filtros y coincidencias más allá de la primera página. |
| Persistencia shared_preferences | CartStorage inyectable; integración escribe/lee con dos instancias reales del plugin y una clave aislada que limpia al terminar. |
| go_router | Rutas catálogo, detalle y carrito. Integración verifica ida y regreso sin perder consulta. Router se libera con su provider. |
| Errores tipados | NetworkFailure, ServerFailure, DataFailure, NotFoundFailure y TimeoutFailure, con tests de cada tipo y recuperación en UI. |
| Tema por provider | Prueba unitaria light/dark y widget que comprueba acceso al botón también a 320 px. |
| riverpod_generator | Anotaciones Riverpod para categorías y detalle; `.g.dart` incluidos. Regeneración verificable con build_runner. |
| Integración buscar-detalle-agregar | `integration_test/catalog_flow_test.dart`, Windows: búsqueda real en UI contra repositorio falso, navegación, carrito y cantidades. Segundo caso valida almacenamiento real. |
| GitHub Action por push | `quality.yml`: on.push, Flutter fijado, analyze/test, integración Windows, Angular formato/lint/build/tests. La configuración está revisada; una nueva ejecución remota requiere publicar la rama. |

## Angular: siete requisitos indispensables

| # | Requisito | Evidencia y comprobación |
| --- | --- | --- |
| 1 | Angular >=17, standalone y strict | Angular 19.2, componentes standalone, strict/strictTemplates. Build de producción y lint. |
| 2 | OrdersService root, HttpClient e interfaces | Servicio tipado; HttpTestingController verifica método GET/datos. Ningún componente usa HttpClient directamente. |
| 3 | Contenedor/tarjeta, input/output | OrdersPageComponent y OrderCardComponent; tests de render y emisión del identificador al pulsar detalle. |
| 4 | Filtro reactivo | FormControl + toSignal + computed: tests de total mínimo, resultado vacío y sin repetir HTTP. |
| 5 | Carga/error | Tests de mensajes de estado y alertas; detalle recupera una nueva navegación después de un error. |
| 6 | Sin suscripciones pendientes | async pipe/toSignal gestionan ciclo de vida; no hay subscribe manual en componentes. shareReplay usa refCount; switchMap descarta el detalle anterior. Revisión estática, no certificación de memoria de un navegador. |
| 7 | >=2 tests | 12 casos en seis specs: servicio, pipe, tarjeta, filtro, detalle y rutas. |

## Angular: cinco deseables

| Punto | Evidencia y comprobación |
| --- | --- |
| Detalle lazy /orders/:id | loadComponent/import dinámico. RouterTestingHarness carga las rutas reales y verifica detalle/regreso. Build genera un chunk de detalle separado. |
| Signals | toSignal y computed para filtro/lista. Test de actualización al cambiar total mínimo. |
| @if/@for con track | Plantillas de lista/detalle revisadas; tests de render/lista vacía. |
| Pipe propio | discountAmount, prueba del cálculo y render del ahorro. |
| OnPush | OrderCardComponent y contenedor/detalle con ChangeDetectionStrategy.OnPush. |

## Recorrido manual para el entrevistador

1. Seguir el inicio rápido del README en dos terminales. No hacen falta secretos ni servidor propio.
2. Flutter: buscar un texto que exista (por ejemplo `phone`), combinar con su categoría y comprobar resultado vacío con una consulta sin coincidencias. Quitar filtros y desplazarse para cargar otra página.
3. Abrir detalle, agregar y abrir carrito. Escribir 50, comprobar total con separadores de miles, sumar/restar y eliminar. Volver al detalle y catálogo; el contador y la consulta se conservan.
4. Agregar un producto y recargar: el carrito persiste en ese navegador/origen. Cambiar tema. Probar a ancho de móvil; el detalle largo se desplaza.
5. Angular: cambiar total mínimo, abrir detalle y volver. Visitar una ruta desconocida: página 404 con enlace de regreso.
6. Para errores, los tests simulan 404, 503, JSON inválido, desconexión y timeout de forma controlada. Se puede desconectar Internet manualmente, pero no hace falta para correr los tests.

## Reproducción y límites

Las instalaciones limpias usan `flutter pub get` y `npm ci`; no dependen de node_modules, build ni archivos ignorados del equipo del autor. El código generado está versionado. Las pruebas de red usan dobles para evitar flakiness por DummyJSON.

No se promete ausencia absoluta de fallos ni disponibilidad perpetua de DummyJSON. No se verificó Android/iOS: Android necesita licencias aceptadas y iOS un equipo macOS. No se incluyen claves de firma release ni despliegue público. Los avisos de dependencias Angular y las mejoras de producción están documentados, sin forzar una migración fuera del alcance.
