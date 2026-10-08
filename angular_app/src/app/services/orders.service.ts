import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Order, OrdersResponse } from '../models/order.model';
import { environment } from '../../environments/environment';
@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);

  getOrders(): Observable<OrdersResponse> {
    return this.http.get<OrdersResponse>(`${environment.apiUrl}/carts`);
  }

  getOrder(id: number): Observable<Order> {
    return this.http.get<Order>(`${environment.apiUrl}/carts/${id}`);
  }
}
