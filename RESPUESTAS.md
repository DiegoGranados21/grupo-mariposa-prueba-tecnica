# Respuestas - Prueba técnica

## Parte 1 - Preguntas conceptuales

1. En Dart, `final` permite asignar un valor una sola vez, incluso si se conoce hasta la ejecución. `const` exige que el valor pueda calcularse en compilación. En Flutter uso `const` cuando los argumentos de un widget también son constantes; así se puede reutilizar esa instancia en lugar de crearla de nuevo.

2. Null safety me obliga a indicar cuándo una variable puede ser nula, por ejemplo `String?`. Con `?.` accedo a ella de forma segura y con `??` defino un valor alternativo. Uso `late` solo si puedo garantizar la inicialización antes de leerla; prefiero evitar `!` cuando puedo comprobar el valor, porque una suposición incorrecta causaría un error en ejecución.

3. Un `StatelessWidget` recibe datos y no administra estado mutable propio. Un `StatefulWidget` tiene un objeto `State`, útil para el ciclo de vida de un controlador de texto, por ejemplo. `ConsumerWidget` permite observar providers con `ref`, y `ConsumerStatefulWidget` combina Riverpod con ese ciclo de vida local.

4. Un `Future` termina con un resultado o un error; lo usaría para consultar un producto por HTTP. Un `Stream` puede emitir varios valores durante su vida, como cambios de ubicación. Elegiría según si necesito una respuesta puntual o actualizaciones continuas.

5. Extraería una parte de la interfaz a una clase de widget cuando tiene una responsabilidad reconocible, recibe datos propios o merece una prueba independiente. Un método `_build...` también puede servir para una sección pequeña; no hace falta crear una clase por cada línea de UI.

6. Riverpod permite separar el estado de la pantalla y sustituir dependencias durante las pruebas. `setState` sigue siendo adecuado para estado local sencillo, como una selección visual; para productos y carrito preferí providers porque varias partes de la app necesitan esos datos. A diferencia de Provider, el acceso no depende de buscar el provider en la posición correcta del árbol de widgets.

7. `ref.watch` observa un provider y actualiza la UI cuando cambia; por eso lo uso al construir widgets. `ref.read` obtiene el notifier para ejecutar una acción desde un callback, como agregar al carrito. `ref.listen` ejecuta un efecto ante un cambio: en el catálogo sincroniza el controlador del campo de búsqueda con el estado compartido de filtros.

8. Uso `Provider` para exponer una dependencia, como el repositorio; `FutureProvider` para una consulta asíncrona simple, como el detalle; `Notifier` para estado síncrono modificable, como el carrito; y `AsyncNotifier` cuando necesito carga remota junto con acciones como buscar, filtrar o reintentar.

9. `autoDispose` permite liberar el estado de un provider cuando deja de usarse, algo útil para datos de una pantalla temporal. `family` crea una instancia según un argumento. En el detalle, `productDetailProvider(id)` permite consultar cada producto por su identificador.

10. `AsyncValue` representa carga, datos y error sin tener que coordinar varias banderas. En la pantalla del catálogo lo manejo así:

```dart
return products.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, _) => Center(child: Text('$error')),
  data: (page) => page.items.isEmpty
      ? const Center(child: Text('No se encontraron productos'))
      : _ProductList(page: page),
);
```

El fragmento resume la idea; la pantalla entregada también muestra un mensaje de error claro y un botón para reintentar.

11. Para probar un provider, reemplazo `productsRepositoryProvider` por un repositorio falso en un `ProviderContainer` o `ProviderScope`. Así puedo simular datos y errores de forma controlada, sin que la prueba dependa de DummyJSON ni de la conexión a Internet.

12. Un componente standalone declara sus dependencias en `imports` y no necesita declararse en un `NgModule`. Un componente tradicional sí pertenece a un módulo. Elegí standalone porque, para esta aplicación pequeña, deja más claro qué usa cada componente.

13. Un `Observable` representa un flujo asíncrono y encaja bien con `HttpClient` y los operadores de RxJS. Un `Signal` conserva un valor actual y recalcula la UI que depende de él. En esta prueba mantuve HTTP como Observable y usé Signals para el filtro y la lista visible.

14. `input()` / `@Input()` permiten recibir datos del padre; `output()` / `@Output()` comunican eventos hacia él. Si dos componentes hermanos necesitan coordinarse, el padre puede recibir el evento y actualizar los datos del otro. Para estado compartido más amplio consideraría un servicio.

15. La inyección de dependencias hace que Angular proporcione a una clase sus colaboradores, en vez de crearlos dentro de ella. Con `providedIn: 'root'`, un servicio queda disponible a nivel de aplicación como una instancia compartida; además, el código no usado puede excluirse del paquete final.

16. Una suscripción de larga duración que no se libera puede conservar referencias o ejecutar lógica después de destruir el componente. Prefiero `async` pipe cuando muestro un Observable en la plantilla, o `takeUntilDestroyed()` si debo suscribirme en TypeScript. Una petición HTTP simple normalmente completa sola, pero aun así debo atender carga y error.

17. El principio de responsabilidad única busca que cada pieza tenga un motivo principal para cambiar. Por eso el repositorio resuelve el acceso a productos, el notifier coordina el estado y el widget muestra la interfaz. Un cambio en la URL de la API no debería requerir modificar la tarjeta visual.

18. En esta solución, `domain` define `Product` y el contrato del repositorio; `data` implementa HTTP y la conversión JSON; `presentation` reúne providers y widgets. La separación me permite probar la pantalla con un repositorio falso y evita que el widget tenga que conocer códigos HTTP o estructuras JSON.

19. Una prueba unitaria revisa una regla aislada, como el cálculo del carrito. Una prueba de widget verifica lo que se muestra y cómo responde una pantalla dentro de Flutter. Una prueba de integración recorre varias piezas juntas, como navegación y persistencia; no todas las pruebas necesitan usar una API real.

20. Intento que cada commit tenga una intención concreta y deje el proyecto en un estado comprobable. Uso mensajes descriptivos, por ejemplo `fix: handle empty cart`. En una solicitud de cambios explicaría qué se modificó, cómo se probó y qué limitaciones quedan, sin mezclar refactorizaciones ajenas al objetivo.

## Parte 4 - Code review

### Fragmento A - Flutter / Riverpod

1. **Petición durante `build`.** Una reconstrucción puede disparar otra llamada HTTP, aunque los datos no hayan cambiado. Movería la carga a un provider asíncrono que controle carga, datos y error; la pantalla solo observaría ese estado.
2. **Responsabilidades mezcladas.** El widget hace la solicitud, interpreta JSON y dibuja la interfaz. Separaría un repositorio para HTTP y conversión de datos, y trabajaría en la UI con objetos `Product` tipados.
3. **Tipos poco claros.** `data`, `List` y `Map` sin tipos concretos hacen más fácil acceder a una clave equivocada o confundir un producto con un artículo del carrito. Definiría `Product` y `CartItem`, con campos y nombres explícitos.
4. **Lectura no reactiva del contador.** Si se usa `ref.read(cartProvider)` para pintarlo, la barra no se reconstruye al cambiar el carrito. Observaría un valor derivado con `ref.watch(cartCountProvider)`.
5. **Mutación directa del carrito.** `ref.read(cartProvider).add(p)` modifica la lista existente, sin publicar un estado nuevo. La acción debería estar en un `CartNotifier`, que cree una lista nueva y actualice `state`.
6. **Estados y limpieza.** También faltan una respuesta para error y lista vacía, validación de códigos HTTP y eliminación de impresiones de depuración. Añadiría `const` y `super.key` donde correspondan, pero priorizaría primero el comportamiento y el manejo de errores.

#### Reescritura propuesta (Flutter)

Este extracto muestra la responsabilidad de la pantalla; presupone los modelos, el repositorio y los providers definidos por separado, como en `flutter_app/lib/`.

```dart
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Productos ($cartCount)')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton(
            onPressed: () => ref.read(productsProvider.notifier).retry(),
            child: const Text('Reintentar'),
          ),
        ),
        data: (page) => page.items.isEmpty
            ? const Center(child: Text('No se encontraron productos'))
            : ListView.builder(
                itemCount: page.items.length,
                itemBuilder: (context, index) {
                  final product = page.items[index];
                  return ListTile(
                    title: Text(product.title),
                    subtitle: Text('\$${product.price}'),
                    onTap: () =>
                        ref.read(cartProvider.notifier).add(product),
                  );
                },
              ),
      ),
    );
  }
}
```

La implementación entregada añade búsqueda, categorías y paginación, que omití en este extracto para destacar la corrección de los problemas del fragmento original.

### Fragmento B - Angular

1. **HTTP dentro del componente.** La pantalla conoce la URL y el formato de la respuesta, además de presentarla. Llevaría la petición a `OrdersService` y devolvería modelos tipados para que el componente se concentre en el estado y la interacción.
2. **Uso de `any`.** Hace que `strict` pierda utilidad y permite errores que TypeScript podría detectar. Definiría interfaces para la respuesta, el pedido y sus productos; así también queda más claro qué datos muestra cada tarjeta.
3. **`setInterval` sin limpieza.** Mantiene las consultas periódicas incluso si el componente ya no está. Si el refresco fuera realmente necesario, lo implementaría con un flujo de RxJS y gestionaría su ciclo de vida; en esta prueba no hacía falta consultar cada cinco segundos.
4. **Estados de la petición.** Una suscripción HTTP individual suele completarse sola, así que no afirmaría que siempre produce una fuga. El problema principal es que el fragmento no muestra carga ni error y deja lógica de suscripción dentro de la pantalla. Preferiría exponer el Observable y consumirlo con `async` pipe.
5. **Presentación acoplada.** Extraería una tarjeta que reciba un pedido y emita la intención de abrirlo. En la lista usaría `track` y en la tarjeta `OnPush`, porque sus datos llegan por entradas bien definidas.
6. **Dependencias de la plantilla.** Si el componente es standalone y usa `*ngFor`, debe importar `NgFor` o `CommonModule`; de lo contrario la plantilla no dispone de esa directiva. En la solución uso `@for`, que no requiere importar `NgFor`, con un identificador estable para seguir cada pedido.
