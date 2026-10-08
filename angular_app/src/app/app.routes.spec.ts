import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { RouterTestingHarness } from '@angular/router/testing';
import { appRoutes } from './app.routes';

describe('Application navigation', () => {
  let http: HttpTestingController;
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideRouter(appRoutes), provideHttpClient(), provideHttpClientTesting()],
    });
    http = TestBed.inject(HttpTestingController);
  });
  afterEach(() => http.verify());

  it('loads the lazy detail and returns to the orders list', async () => {
    const harness = await RouterTestingHarness.create('/');
    http.expectOne('https://dummyjson.com/carts').flush({ carts: [] });
    harness.detectChanges();
    await harness.navigateByUrl('/orders/4');
    http.expectOne('https://dummyjson.com/carts/4').flush({
      id: 4,
      userId: 7,
      products: [],
      total: 80,
      discountedTotal: 70,
      totalProducts: 0,
      totalQuantity: 0,
    });
    harness.detectChanges();
    expect(harness.routeNativeElement?.textContent).toContain('Pedido #4');
    const backLink = harness.routeNativeElement?.querySelector('a') as HTMLAnchorElement;
    expect(backLink.getAttribute('href')).toBe('/');
    await harness.navigateByUrl('/');
    http.expectOne('https://dummyjson.com/carts').flush({ carts: [] });
    harness.detectChanges();
    expect(harness.routeNativeElement?.textContent).toContain('Panel de pedidos');
  });

  it('shows a recoverable not-found page for unknown routes', async () => {
    const harness = await RouterTestingHarness.create('/unknown-page');
    expect(harness.routeNativeElement?.textContent).toContain('Página no encontrada');
    expect(harness.routeNativeElement?.querySelector('a')?.getAttribute('href')).toBe('/');
  });
});
