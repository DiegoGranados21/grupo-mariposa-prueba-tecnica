# Respuestas - Prueba técnica

## Parte 1 - Preguntas conceptuales

1. `final` permite asignar una variable una sola vez en tiempo de ejecución. `const` representa un valor conocido en compilación e inmutable. Un widget `const` puede reutilizarse cuando su padre se reconstruye, por eso reduce trabajo innecesario cuando sus argumentos son constantes.

2. Null safety obliga a declarar si un valor puede ser nulo: `String?`. Uso `?.` para acceder solo si existe, `??` para un valor por defecto y `late` cuando sé que una variable no nula se inicializará antes de leerla. `!` fuerza que algo no es nulo; abusar de él convierte un posible error controlable en una excepción en ejecución.

3. `StatelessWidget` no guarda estado interno mutable; `StatefulWidget` tiene un objeto `State` que puede cambiar y reconstruirse. `ConsumerWidget` aporta acceso a `ref` en un widget sin estado. `ConsumerStatefulWidget` combina ese acceso con ciclo de vida local, útil por ejemplo para un `TextEditingController`.

4. Un `Future` produce un resultado o error una sola vez, por ejemplo una petición HTTP para obtener un producto. Un `Stream` puede emitir varios valores a lo largo del tiempo, por ejemplo actualizaciones de ubicación o una colección de Firebase.

5. Una clase propia hace el widget reutilizable, más fácil de probar y de identificar en el árbol de widgets. También limita qué datos necesita mediante su constructor; un método `_buildAlgo` suele terminar acoplado al estado de toda la pantalla.

6. Riverpod separa el estado de la UI, permite leerlo sin depender del `BuildContext` y facilita sobreescribir dependencias en tests. Frente a `setState`, evita concentrar la lógica de negocio en una pantalla. Frente al Provider clásico, tiene mejor seguridad de tipos y no depende de la posición en el árbol.

7. `ref.watch` escucha cambios y se usa normalmente en `build`. `ref.read` obtiene el valor/objeto una vez, adecuado para callbacks que ejecutan acciones. `ref.listen` reacciona a cambios con efectos secundarios, como mostrar un diálogo. Es incorrecto usar `ref.read` en `build` si la interfaz debe actualizarse al cambiar ese provider.

8. Uso `Provider` para valores derivados o dependencias sin estado, como un repositorio. `FutureProvider` sirve para una consulta asíncrona simple. `Notifier` sirve para estado síncrono modificable, como el carrito. `AsyncNotifier` combina acciones y estado asíncrono, como cargar y buscar productos.

9. `autoDispose` libera un provider cuando ya no tiene oyentes, útil para evitar conservar pantallas o datos transitorios. `family` crea una instancia según un parámetro; por ejemplo, una consulta de producto diferente por cada `id`.

10. `AsyncValue` representa los tres estados sin banderas manuales:

```dart
return products.when(
  data: (items) => ProductsList(items: items),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, _) => RetryView(message: '$error'),
);
```

11. Creo un `ProviderContainer` o `ProviderScope` y reemplazo el provider del repositorio por uno falso. Así la prueba no hace red real: `overrides: [productsRepositoryProvider.overrideWithValue(FakeProductsRepository())]`.

12. Un componente standalone declara directamente sus imports y no necesita pertenecer a un `NgModule`. Un componente tradicional se declara en un módulo que agrupa dependencias. Standalone hace más local y explícita la dependencia del componente.

13. Un `Observable` puede representar valores asíncronos a lo largo del tiempo y se integra bien con HTTP, eventos y operadores RxJS. Un `Signal` guarda estado actual y notifica a quien lo lea. Preferiría Observable para el flujo HTTP y Signal para estado local derivado de filtros o UI.

14. `input()` / `@Input()` reciben datos del padre y `output()` / `@Output()` emiten eventos al padre. Dos hermanos no deberían comunicarse directamente: el hijo emite al padre y este actualiza el input del otro, o comparten un servicio si el estado es global.

15. La inyección de dependencias entrega a una clase los objetos que necesita, en vez de que los construya. `providedIn: 'root'` registra un singleton disponible para toda la aplicación y permite que Angular lo elimine si nadie lo usa.

16. Una suscripción que sigue viva puede actualizar un componente destruido o retener memoria. Puedo evitarlo con `async` pipe en la plantilla, con `takeUntilDestroyed()` o cancelando manualmente la suscripción en `ngOnDestroy`.

17. SRP dice que una clase debe tener una razón principal para cambiar. En Flutter separaría el cliente HTTP, repositorio, notifier y widget: cambiar la API no debería obligar a modificar la tarjeta visual de producto.

18. Presentación contiene widgets, providers y navegación; dominio contiene entidades y contratos; datos contiene DTO, fuente remota y repositorios concretos. Esto reduce acoplamiento: la capa visual conoce una abstracción, no detalles HTTP.

19. Una prueba unitaria verifica una clase o función aislada, por ejemplo el total del carrito. Una prueba de widget prueba UI e interacción dentro del motor Flutter. Una prueba de integración recorre una funcionalidad completa, potencialmente incluyendo navegación, almacenamiento o una API simulada.

20. Uso mensajes cortos en imperativo con un prefijo consistente como `feat:` o `fix:`. Hago commits pequeños que compilan y prueban una intención. En un PR incluyo contexto, cómo probarlo, capturas si corresponde y no mezclo refactors no relacionados.

## Parte 4 - Code review

### Fragmento A - Flutter / Riverpod

1. La petición HTTP ocurre dentro de `build`, por lo que cada reconstrucción puede crear otra petición y otro `setState`. Importa porque produce tráfico repetido, estados inestables y posibles llamadas después de `dispose`. La solución es cargar mediante un repositorio y un `AsyncNotifier` / `FutureProvider`.
2. La pantalla mezcla UI, HTTP, parseo JSON y estado. Eso dificulta pruebas y hace que la UI dependa de infraestructura. Extraería un datasource/repositorio y expondría entidades tipadas e inmutables.
3. `data`, `List` y `Map` no están tipados, y `var cartProvider` no explica su intención. Usaría `List<Product>` y una entidad `CartItem` con nombres explícitos.
4. `ref.read(cartProvider)` se usa para pintar el contador: no escucha cambios, por eso la AppBar no se actualiza. Debe ser `ref.watch` dentro de `build`.
5. `ref.read(cartProvider).add(p)` muta la lista retornada, sin asignar nuevo estado; Riverpod no tiene por qué notificar el cambio. Un `CartNotifier` debe crear una lista nueva y actualizar `state`.
6. Falta manejo de error, lista vacía, código HTTP no exitoso, `const`, key pública en widgets y se deja un `print` de depuración.

#### Reescritura propuesta (Flutter)

```dart
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return HttpProductsRepository();
});

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).getProducts();
});

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartProvider.select((items) => items.length));

    return Scaffold(
      appBar: AppBar(title: Text('Productos ($cartCount)')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(productsProvider),
            child: const Text('Reintentar'),
          ),
        ),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) => ListTile(
            title: Text(items[index].title),
            subtitle: Text('\$${items[index].price}'),
            onTap: () => ref.read(cartProvider.notifier).add(items[index]),
          ),
        ),
      ),
    );
  }
}
```

### Fragmento B - Angular

1. El componente llama directamente a `HttpClient`, por lo que mezcla infraestructura y presentación. Movería esa llamada a `OrdersService`, con interfaces para la respuesta.
2. `any` elimina el beneficio de TypeScript strict y oculta errores de forma de datos. Definiría `Order`, `CartProduct` y `CartsResponse`.
3. `setInterval` crea peticiones cada cinco segundos y nunca se limpia. Esto genera fugas al destruir el componente y tráfico innecesario. Si se requiere refresco, usaría RxJS con `timer` y `async` pipe o `takeUntilDestroyed`.
4. El `subscribe` no se cancela y no se gestionan carga ni error. Expondría un Observable y lo consumiría con `async` pipe; la plantilla mostraría estados explícitos.
5. Falta separación contenedor/presentación, `trackBy` o `track` al iterar, tipado de respuesta y configuración `OnPush` para el componente visual.
