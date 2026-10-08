# Revisión de mejoras recomendadas

Se cotejaron las recomendaciones con el PDF original, no solo con el checklist anterior. El alcance sigue siendo un catálogo Flutter y un panel Angular de nivel Junior, sin pagos, autenticación ni infraestructura adicional.

| Recomendación | Evaluación y decisión |
| --- | --- |
| 1. Búsqueda y filtros | Aplicada. `CatalogFilters` reúne consulta/categoría. Se preservan datos durante una actualización y se rechazan respuestas obsoletas. Ambos filtros se combinan, como exige el deseable. |
| 2. Errores tipados | Aplicada. 404 propio, timeout de 15 segundos, cierre del cliente HTTP y reintento en detalle. |
| 3. Pruebas y cobertura | Aplicada. Debounce con `fakeAsync`, dos `Completer` fuera de orden, error/reintento inicial y con datos previos, fallo de paginación, filtro combinado y detalle recuperable. Angular prueba el filtro y el detalle y genera cobertura. |
| 4. Formato y lint | Aplicada. Dart format, Prettier y ESLint con reglas Angular. Son comandos locales y pasos obligatorios en CI. |
| 5. CI | Aplicada. Flutter 3.47.6, permisos de solo lectura, concurrencia y cancelación de ejecuciones anteriores. Se ejecuta con cada push y manualmente; no se duplica con un segundo trigger pull_request. Esto conserva el bonus del enunciado de verificar cada push. |
| 6. Configuración | Aplicada con límites. Identificador Android propio, Internet en manifiesto principal, sin firma release de debug; API Angular centralizada y SDK/documentación alineados. Una firma de producción requiere claves privadas del propietario y no es parte de la evaluación. |
| 7. Documentación | Aplicada. README explica filtros combinados, generación, versiones, pruebas, ejecución y límites. RESPUESTAS refleja el uso real de `ref.listen`. |
| 8. Accesibilidad | Aplicada. Feedback al agregar, descripciones de imágenes, nombres por pedido, mensajes de carga/error y foco visible. No se afirma cumplimiento WCAG completo sin auditoría manual y automatizada adicional. |
| 9. Dinero | Documentada. Se mantiene `double` para no introducir una migración innecesaria en un catálogo sin cobros. Para producción corresponde decimal o centavos enteros. |
| 10. Git | Se trabaja en una rama de revisión. No se reescriben commits existentes. Los cambios nuevos se agrupan por intención; publicar o abrir un PR requiere autorización del usuario. |
| 11. Menores | Página 404 Angular añadida. Se mantiene `standalone: true` por claridad. El provider del catálogo conserva lista/filtros intencionalmente; el detalle es autoDispose. |

## Dos ajustes adicionales exigidos por el PDF

- El filtro por categoría debía poder combinarse con la búsqueda, no sustituirla. DummyJSON documenta que `limit=0` devuelve todos los elementos; el repositorio filtra la categoría completa antes de paginar. [Documentación de productos de DummyJSON](https://dummyjson.com/docs/products).
- El bonus de generación pedía `riverpod_generator` con anotaciones, no únicamente JSON generado. Ahora categorías y detalle usan anotaciones; la prueba de integración comienza buscando y continúa al detalle y carrito.

## Criterios para mantener una solución sencilla

No se agregaron servicios backend, pagos, claves de firma ni abstracciones nuevas para cada operación. Riverpod 3 sustituye a Riverpod 2 porque su generador anterior no es compatible con el SDK actual; ambos están permitidos por el enunciado. Se conservaron `Notifier`, `AsyncNotifier`, el contrato del repositorio y las pantallas. Los reintentos son explícitos para no repetir silenciosamente errores como un 404.

Quedan fuera de esta entrega una auditoría WCAG formal, seguridad de producción, una migración mayor de Angular y el uso de dinero decimal. El README explica estas limitaciones; no se presentan como requisitos ya certificados.
