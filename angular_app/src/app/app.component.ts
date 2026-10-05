import { Component } from '@angular/core';
import { OrdersPageComponent } from './orders/orders-page.component';
@Component({ selector: 'app-root', standalone: true, imports: [OrdersPageComponent], template: '<app-orders-page />' })
export class AppComponent {}
