# Architecture Upgrade: Auth, RBAC & Reactive Integration

## 1. Role-Based Access Control (RBAC) Matrix
- **Admin / Owner**: Akses penuh (POS Cashier, Menu CRUD, Category & Modifier CRUD, Order History, Void/Refund, Shift Management, User CRUD).
- **Manager**: Akses operasional (POS Cashier, Menu Stock Toggle, Order History, Void/Refund via PIN, Shift Closing). Tidak bisa hapus Menu/User permanen.
- **Cashier**: Akses terbatas (POS Cashier, Buat Order, Hold Order, Riwayat Order shift aktif). Void/Refund membutuhkan pop-up PIN Manager/Admin. MenuNavigationRail menyembunyikan tab Menu/Category CRUD.

## 2. Updated Database Schema (Drift / SQLite)
- **users**: `id` (PK, Int), `name` (Text), `username` (Text, Unique), `pin_hash` (Text, 6-digit untuk fast POS login/override), `role` (Enum: admin, manager, cashier), `is_active` (Bool).
- **shifts**: `id` (PK, Int), `user_id` (FK -> users.id), `opened_at` (DateTime), `closed_at` (DateTime, Nullable), `starting_cash` (Int), `expected_cash` (Int), `actual_cash` (Int, Nullable), `status` (Enum: open, closed).
- **modifier_groups**: `id` (PK, Int), `name` (Text), `is_required` (Bool), `min_select` (Int), `max_select` (Int).
- **modifier_options**: `id` (PK, Int), `group_id` (FK -> modifier_groups.id), `name` (Text), `extra_price` (Int).
- **product_modifiers**: `product_id` (FK -> products.id), `group_id` (FK -> modifier_groups.id).
- **orders (Update)**: Tambahkan `user_id` (FK -> users.id), `shift_id` (FK -> shifts.id), `voided_by` (FK -> users.id, Nullable), `void_reason` (Text, Nullable).

## 3. End-to-End Reactive Data Flows (Zero Hardcode Rules)
1. **Auth & Shift Flow**: Login (Pilih Profil / Input PIN) -> Cek `shifts` aktif -> Jika belum ada, wajib buka modal "Open Shift" (input modal kas awal) sebelum masuk ke layar POS.
2. **Category & Modifier -> POS Catalog**: Riverpod `StreamProvider` memantau tabel `categories`, `products`, dan `modifier_groups`. Perubahan CRUD langsung mengubah tab kategori, status *Sold Out*, dan opsi *modifier* di layar POS secara *real-time*.
3. **Checkout -> Inventory & Shift**: Saat tombol "Complete Payment" ditekan, jalankan `db.transaction()`:
   - Simpan record ke `orders` & `order_items` (termasuk `user_id` & `shift_id` aktif).
   - Kurangi `stock` di tabel `products` sesuai `qty` yang dibeli. Jika `stock <= 0`, otomatis ubah `is_available = false`.
   - Jika metode pembayaran `Cash`, tambahkan nilai transaksi ke `expected_cash` pada `shifts` yang sedang aktif.
4. **Void / Refund -> Rollback**: Saat order di-Void (dengan otorisasi PIN Manager/Admin):
   - Ubah status order menjadi `void`.
   - Kembalikan jumlah `stock` produk terkait di tabel `products`.
   - Kurangi `expected_cash` di tabel `shifts` dan perbarui metrik KPI di layar Order History secara otomatis.