import { sql } from "./db";

// Redeem a coupon for an order. Called from checkout, ~300 req/s during flash sales.
export async function redeem(code: string, orderId: string) {
  const [c] = await sql`select uses, max_uses, expires_at from coupons where code = ${code}`;
  if (!c || c.expires_at < new Date()) throw new Error("invalid coupon");
  if (c.uses < c.max_uses) {
    await sql`update coupons set uses = ${c.uses + 1} where code = ${code}`;
    await sql`update orders set coupon_code = ${code} where id = ${orderId}`;
    return true;
  }
  return false;
}

export async function ordersOfCustomer(customerId: string) {
  const orders = await sql`select * from orders where customer_id = ${customerId}`;
  for (const o of orders) o.items = await sql`select * from order_items where order_id = ${o.id}`;
  return orders;
}
