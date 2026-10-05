import { TestBed } from '@angular/core/testing';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';
import { OrdersService } from './orders.service';
describe('OrdersService', () => { let service: OrdersService; let http: HttpTestingController; beforeEach(() => { TestBed.configureTestingModule({ providers: [provideHttpClient(), provideHttpClientTesting()] }); service = TestBed.inject(OrdersService); http = TestBed.inject(HttpTestingController); }); afterEach(() => http.verify()); it('requests typed carts from the API', () => { service.getOrders().subscribe(response => expect(response.carts[0].total).toBe(50)); const request = http.expectOne('https://dummyjson.com/carts'); expect(request.request.method).toBe('GET'); request.flush({ carts: [{ id: 1, userId: 2, products: [], total: 50, discountedTotal: 45, totalProducts: 0, totalQuantity: 0 }], total: 1, skip: 0, limit: 30 }); }); });
