import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { OrdersPageComponent } from './orders-page.component';

describe('OrdersPageComponent', () => {
  let fixture: ComponentFixture<OrdersPageComponent>;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [OrdersPageComponent],
      providers: [provideHttpClient(), provideHttpClientTesting(), provideRouter([])],
    });
    http = TestBed.inject(HttpTestingController);
    fixture = TestBed.createComponent(OrdersPageComponent);
    fixture.detectChanges();
  });
  afterEach(() => http.verify());

  it('announces loading before the response', () => {
    expect(fixture.nativeElement.querySelector('[role="status"]').textContent).toContain(
      'Cargando pedidos',
    );
    http.expectOne('https://dummyjson.com/carts').flush({ carts: [] });
  });

  it('filters orders by the entered minimum without requesting again', () => {
    http.expectOne('https://dummyjson.com/carts').flush({
      carts: [
        {
          id: 1,
          userId: 1,
          total: 50,
          discountedTotal: 45,
          totalProducts: 0,
          totalQuantity: 0,
          products: [],
        },
        {
          id: 2,
          userId: 1,
          total: 200,
          discountedTotal: 180,
          totalProducts: 0,
          totalQuantity: 0,
          products: [],
        },
      ],
    });
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelectorAll('app-order-card').length).toBe(2);
    fixture.componentInstance.minimumControl.setValue(100);
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelectorAll('app-order-card').length).toBe(1);
    expect(fixture.nativeElement.textContent).toContain('Pedido #2');
    fixture.componentInstance.minimumControl.setValue(300);
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('No hay pedidos con ese total');
  });

  it('announces a request error', () => {
    http
      .expectOne('https://dummyjson.com/carts')
      .flush({}, { status: 503, statusText: 'Unavailable' });
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('[role="alert"]').textContent).toContain(
      'No se pudieron cargar',
    );
  });
});
