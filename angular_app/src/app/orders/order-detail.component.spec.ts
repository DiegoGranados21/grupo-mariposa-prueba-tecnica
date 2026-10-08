import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute, convertToParamMap, provideRouter } from '@angular/router';
import { BehaviorSubject } from 'rxjs';
import { OrderDetailComponent } from './order-detail.component';

describe('OrderDetailComponent', () => {
  let fixture: ComponentFixture<OrderDetailComponent>;
  let http: HttpTestingController;
  let params: BehaviorSubject<ReturnType<typeof convertToParamMap>>;

  beforeEach(() => {
    params = new BehaviorSubject(convertToParamMap({ id: '4' }));
    TestBed.configureTestingModule({
      imports: [OrderDetailComponent],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        provideRouter([]),
        { provide: ActivatedRoute, useValue: { paramMap: params.asObservable() } },
      ],
    });
    http = TestBed.inject(HttpTestingController);
    fixture = TestBed.createComponent(OrderDetailComponent);
    fixture.detectChanges();
  });
  afterEach(() => http.verify());

  it('announces loading before the first response', () => {
    expect(fixture.nativeElement.querySelector('[role="status"]').textContent).toContain(
      'Cargando pedido',
    );
    http
      .expectOne('https://dummyjson.com/carts/4')
      .flush({ id: 4, total: 80, discountedTotal: 70, products: [] });
  });

  it('renders the order and its products', () => {
    http.expectOne('https://dummyjson.com/carts/4').flush({
      id: 4,
      userId: 7,
      total: 80,
      discountedTotal: 70,
      products: [{ id: 1, title: 'Phone', quantity: 2 }],
    });
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('Pedido #4');
    expect(fixture.nativeElement.textContent).toContain('2 × Phone');
    expect(fixture.nativeElement.textContent).toContain('$80.00');
    expect(fixture.nativeElement.querySelector('[role="status"]')).toBeNull();
  });

  it('handles an error and can load another route afterward', () => {
    http
      .expectOne('https://dummyjson.com/carts/4')
      .flush({}, { status: 404, statusText: 'Not Found' });
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('[role="alert"]')).not.toBeNull();
    params.next(convertToParamMap({ id: '5' }));
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('[role="status"]')).not.toBeNull();
    http
      .expectOne('https://dummyjson.com/carts/5')
      .flush({ id: 5, total: 25, discountedTotal: 20, products: [] });
    fixture.detectChanges();
    expect(fixture.nativeElement.textContent).toContain('Pedido #5');
  });
});
