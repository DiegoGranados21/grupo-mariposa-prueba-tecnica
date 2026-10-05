export interface CartProduct { id: number; title: string; price: number; quantity: number; total: number; discountPercentage: number; }
export interface Order { id: number; userId: number; products: CartProduct[]; total: number; discountedTotal: number; totalProducts: number; totalQuantity: number; }
export interface OrdersResponse { carts: Order[]; total: number; skip: number; limit: number; }
