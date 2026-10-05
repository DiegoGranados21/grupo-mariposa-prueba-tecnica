import { Routes } from '@angular/router';

import { OrdersPageComponent } from './orders/orders-page.component';

export const appRoutes: Routes = [
  { path: '', pathMatch: 'full', component: OrdersPageComponent },
  {
    path: 'orders/:id',
    loadComponent: () =>
      import('./orders/order-detail.component').then(
        (module) => module.OrderDetailComponent,
      ),
  },
  { path: '**', redirectTo: '' },
];
