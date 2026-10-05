import { AsyncPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { catchError, map, of, shareReplay, startWith } from 'rxjs';

import { Order } from '../models/order.model';
import { OrdersService } from '../services/orders.service';
import { OrderCardComponent } from './order-card.component';

type OrdersState = {
  loading: boolean;
  orders: Order[];
  error: string | null;
};

@Component({
  selector: 'app-orders-page',
  standalone: true,
  imports: [AsyncPipe, ReactiveFormsModule, OrderCardComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <main>
      <h1>Panel de pedidos</h1>
      <label for="minimum">Total mínimo</label>
      <input id="minimum" type="number" [formControl]="minimumControl" min="0" />

      @if (state$ | async; as state) {
        @if (state.loading) {
          <p>Cargando pedidos...</p>
        } @else if (state.error) {
          <p class="error">{{ state.error }}</p>
        } @else {
          <p>{{ filteredOrders().length }} pedidos encontrados</p>
          <section class="orders">
            @for (order of filteredOrders(); track order.id) {
              <app-order-card [order]="order" (view)="showOrder($event)" />
            } @empty {
              <p>No hay pedidos con ese total.</p>
            }
          </section>
        }
      }
    </main>
  `,
})
export class OrdersPageComponent {
  private readonly ordersService = inject(OrdersService);
  private readonly router = inject(Router);

  readonly minimumControl = new FormControl(0, { nonNullable: true });
  private readonly minimum = toSignal(
    this.minimumControl.valueChanges.pipe(startWith(0)),
    { initialValue: 0 },
  );

  readonly state$ = this.ordersService.getOrders().pipe(
    map(
      (response): OrdersState => ({
        loading: false,
        orders: response.carts,
        error: null,
      }),
    ),
    startWith({ loading: true, orders: [], error: null } as OrdersState),
    catchError(() =>
      of({
        loading: false,
        orders: [],
        error: 'No se pudieron cargar los pedidos. Intenta de nuevo.',
      } as OrdersState),
    ),
    shareReplay({ bufferSize: 1, refCount: true }),
  );

  private readonly orders = toSignal(
    this.state$.pipe(map((state) => state.orders)),
    { initialValue: [] as Order[] },
  );

  readonly filteredOrders = computed(() =>
    this.orders().filter((order) => order.total >= this.minimum()),
  );

  showOrder(id: number): void {
    void this.router.navigate(['/orders', id]);
  }
}
