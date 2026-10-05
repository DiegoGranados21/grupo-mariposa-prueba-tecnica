import { AsyncPipe, CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { catchError, map, of, switchMap } from 'rxjs';

import { OrdersService } from '../services/orders.service';

@Component({
  selector: 'app-order-detail',
  standalone: true,
  imports: [AsyncPipe, CurrencyPipe, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <main>
      <a routerLink="/">← Volver a pedidos</a>

      @if (order$ | async; as state) {
        @if (state.error) {
          <p class="error">No se pudo cargar el pedido.</p>
        } @else if (state.order; as order) {
          <h1>Pedido #{{ order.id }}</h1>
          <p>Usuario: {{ order.userId }}</p>
          <p>Total: <strong>{{ order.total | currency: 'USD' }}</strong></p>
          <h2>Productos</h2>
          <ul>
            @for (product of order.products; track product.id) {
              <li>{{ product.quantity }} × {{ product.title }}</li>
            }
          </ul>
        } @else {
          <p>Cargando pedido...</p>
        }
      }
    </main>
  `,
})
export class OrderDetailComponent {
  private readonly route = inject(ActivatedRoute);
  private readonly ordersService = inject(OrdersService);

  readonly order$ = this.route.paramMap.pipe(
    map((params) => Number(params.get('id'))),
    switchMap((id) => this.ordersService.getOrder(id)),
    map((order) => ({ order, error: false })),
    catchError(() => of({ order: null, error: true })),
  );
}
