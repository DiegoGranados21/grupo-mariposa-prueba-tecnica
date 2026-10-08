import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';

import { Order } from '../models/order.model';
import { DiscountAmountPipe } from './discount-amount.pipe';

@Component({
  selector: 'app-order-card',
  standalone: true,
  imports: [CurrencyPipe, DiscountAmountPipe],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <article class="card">
      <h2>Pedido #{{ order().id }}</h2>
      <p>Usuario: {{ order().userId }} · {{ order().totalProducts }} productos</p>
      <p>
        Total: <strong>{{ order().total | currency: 'USD' }}</strong>
      </p>
      <p>Ahorro: {{ order().total | discountAmount: order().discountedTotal | currency: 'USD' }}</p>
      <button
        type="button"
        [attr.aria-label]="'Ver detalle del pedido ' + order().id"
        (click)="view.emit(order().id)"
      >
        Ver detalle
      </button>
    </article>
  `,
})
export class OrderCardComponent {
  readonly order = input.required<Order>();
  readonly view = output<number>();
}
