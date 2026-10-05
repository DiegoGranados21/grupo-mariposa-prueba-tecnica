import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Order, OrdersResponse } from '../models/order.model';
@Injectable({ providedIn: 'root' })
export class OrdersService {
  private readonly http = inject(HttpClient);

  getOrders(): Observable<OrdersResponse> {
    return this.http.get<OrdersResponse>('https://dummyjson.com/carts');
  }

  getOrder(id: number): Observable<Order> {
    return this.http.get<Order>(`https://dummyjson.com/carts/${id}`);
  }
}
