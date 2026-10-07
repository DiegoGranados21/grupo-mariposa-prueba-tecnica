import { DiscountAmountPipe } from './discount-amount.pipe';

describe('DiscountAmountPipe', () => {
  it('calculates savings without returning a negative amount', () => {
    const pipe = new DiscountAmountPipe();
    expect(pipe.transform(100, 80)).toBe(20);
    expect(pipe.transform(80, 100)).toBe(0);
  });
});
