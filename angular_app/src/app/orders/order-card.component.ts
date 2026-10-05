import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { Order } from '../models/order.model';
@Component({ selector: 'app-order-card', standalone: true, imports: [CurrencyPipe], changeDetection: ChangeDetectionStrategy.OnPush, template: `<article class="card"><h2>Pedido #{{ order().id }}</h2><p>Usuario: {{ order().userId }} · {{ order().totalProducts }} productos</p><p>Total: <strong>{{ order().total | currency:'USD' }}</strong></p><button type="button" (click)="view.emit(order().id)">Ver detalle</button></article>` })
export class OrderCardComponent { readonly order = input.required<Order>(); readonly view = output<number>(); }
