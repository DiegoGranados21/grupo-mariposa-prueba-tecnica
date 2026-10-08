import { ComponentFixture, TestBed } from '@angular/core/testing';

import { OrderCardComponent } from './order-card.component';

describe('OrderCardComponent', () => {
  let fixture: ComponentFixture<OrderCardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OrderCardComponent],
    }).compileComponents();
    fixture = TestBed.createComponent(OrderCardComponent);
    fixture.componentRef.setInput('order', {
      id: 4,
      userId: 7,
      products: [],
      total: 80,
      discountedTotal: 70,
      totalProducts: 0,
      totalQuantity: 0,
    });
    fixture.detectChanges();
  });

  it('renders the order id, total and savings', () => {
    const text = fixture.nativeElement.textContent as string;
    expect(text).toContain('Pedido #4');
    expect(text).toContain('$80.00');
    expect(text).toContain('Ahorro: $10.00');
  });

  it('emits the order identifier when its accessible detail button is clicked', () => {
    const emitted: number[] = [];
    fixture.componentInstance.view.subscribe((id) => emitted.push(id));
    const button = fixture.nativeElement.querySelector('button') as HTMLButtonElement;
    expect(button.getAttribute('aria-label')).toContain('4');
    button.click();
    expect(emitted).toEqual([4]);
  });
});
