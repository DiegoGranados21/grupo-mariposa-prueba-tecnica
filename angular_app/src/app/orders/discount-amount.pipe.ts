import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'discountAmount', standalone: true, pure: true })
export class DiscountAmountPipe implements PipeTransform {
  transform(total: number, discountedTotal: number): number {
    return Math.max(0, total - discountedTotal);
  }
}
