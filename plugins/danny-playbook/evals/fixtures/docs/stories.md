### [ ] CPN-01 Apply a coupon at checkout (M)
As a shopper, I want to enter a coupon code at checkout, so that I get the discount.
- Coupons have: code, percent_off (1-100) or amount_off (VND), min_order_vnd, max_uses (global), one use per user, expires_at.
- Given a valid coupon and an eligible cart, When I apply it, Then the total shows the discount.
- Given an invalid code, Then I see "Mã không hợp lệ".
