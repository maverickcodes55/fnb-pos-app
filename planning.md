# F&B POS System - Architecture & Implementation Plan
Catatan : Aplikasi menggunakan bahasa indonesia kecuali istilah/menu yang lazim menggunakan bahasa inggris/bahasa lain

## 1. Core Value & MVP Scope
* **Fast Order & Checkout**: Antarmuka kasir *split-screen* responsif untuk input pesanan cepat (Dine-in / Takeaway), kalkulasi pajak/diskon otomatis, dan pencatatan pembayaran (Tunai/QRIS/Kartu).
* **Menu & Category CRUD**: Manajemen produk F&B (tambah, edit, hapus, status ketersediaan/stok habis) beserta pengelompokan kategori.
* **Table & Order Queue Management**: Pencatatan nomor meja untuk *Dine-in* dan pemantauan status pesanan aktif (*Pending*, *Cooking*, *Completed*, *Cancelled*).
* **Transaction History & Daily Summary**: Riwayat nota transaksi (dengan opsi cetak/ekspor struk) dan ringkasan pendapatan harian sederhana.

## 2. Tech Stack & Libraries
* **Framework**: Flutter (Target: Windows, macOS, Android Tablet, iPadOS).
* **State Management & DI**: `flutter_riverpod` + `riverpod_annotation` (Reaktif, *type-safe*, minim *boilerplate*).
* **Local Database**: `drift` + `sqlite3_flutter_libs` (Relasional, mendukung *query* transaksi kompleks dan *offline-first*).
* **Routing**: `go_router` (Navigasi berbasis URL/path untuk layout *ShellRoute* Desktop/Tablet).
* **Data Modeling**: `freezed` + `json_serializable` (Immutability dan serialisasi data).
* **UI & Utility**: `flex_color_scheme` (Theming), `lucide_icons` (Ikon bersih), `intl` (Format mata uang & tanggal), `esc_pos_utils_plus` (Standar format struk thermal).

## 3. Database Schema (Drift / SQLite)
```text
Categories
- id: Int (PK, AutoIncrement)
- name: Text
- icon_name: Text
- is_active: Bool (Default: true)

Products
- id: Int (PK, AutoIncrement)
- category_id: Int (FK -> Categories.id)
- name: Text
- sku: Text (Unique)
- price: Int (disimpan dalam satuan terkecil/Rupiah)
- image_path: Text (Nullable)
- is_available: Bool (Default: true)

Tables
- id: Int (PK, AutoIncrement)
- table_number: Text (Unique)
- capacity: Int
- status: Text (Enum: 'available', 'occupied')

Orders
- id: Int (PK, AutoIncrement)
- order_number: Text (Unique, Format: ORD-YYYYMMDD-XXX)
- table_id: Int (FK -> Tables.id, Nullable untuk Takeaway)
- order_type: Text (Enum: 'dine_in', 'takeaway')
- status: Text (Enum: 'pending', 'completed', 'cancelled')
- subtotal: Int
- tax_amount: Int
- discount_amount: Int
- total_amount: Int
- payment_method: Text (Enum: 'cash', 'qris', 'debit')
- created_at: DateTime

OrderItems
- id: Int (PK, AutoIncrement)
- order_id: Int (FK -> Orders.id, Cascade Delete)
- product_id: Int (FK -> Products.id)
- product_name: Text (Snapshot nama saat transaksi)
- price_at_sale: Int (Snapshot harga saat transaksi)
- quantity: Int
- notes: Text (Nullable, misal: "Less sugar, pedas")
```

## 4. Screen List & User Flow
* **Main Shell Layout (`ShellRoute`)**: Kerangka utama aplikasi dengan *Navigation Rail* di sisi kiri untuk berpindah antar modul utama secara instan di layar lanskap.
* **POS Cashier Screen (`/pos`)**: Layar terbagi dua; sisi kiri (65%) menampilkan grid produk dengan filter kategori & pencarian, sisi kanan (35%) menampilkan keranjang pesanan aktif, pilihan meja/tipe order, dan tombol bayar.
* **Active Orders & Tables Screen (`/orders`)**: Menampilkan daftar pesanan yang sedang berjalan dan status ketersediaan meja dalam bentuk grid visual. Kasir dapat mengubah status pesanan menjadi selesai atau mengosongkan meja.
* **Menu Management Screen (`/catalog`)**: Tabel data interaktif untuk CRUD Produk dan Kategori lengkap dengan fitur pencarian, filter status ketersediaan, dan *modal form* input data.
* **Transaction & Report Screen (`/reports`)**: Menampilkan daftar riwayat transaksi berdasarkan rentang tanggal beserta kartu ringkasan total omzet dan jumlah pesanan. Klik pada baris transaksi akan menampilkan detail struk di panel samping.

## 5. Directory Structure (Feature-First)
```text
lib/
├── core/
│   ├── constants/       # App sizes, breakpoints, default values
│   ├── database/        # Drift database setup, tables.dart, daos/
│   ├── router/          # GoRouter configuration
│   ├── theme/           # AppTheme, color palettes, typography
│   └── utils/           # Currency formatter, date helper
├── shared/
│   └── widgets/         # Reusable UI (CustomButton, EmptyState, ResponsiveSplitView)
├── features/
│   ├── pos/             # Cashier grid, cart controller, checkout modal
│   ├── orders/          # Active orders queue, table status management
│   ├── catalog/         # Product & Category CRUD tables, forms, controllers
│   └── reports/         # Sales summary cards, transaction history list
└── main.dart            # App entry point & ProviderScope
```

## 6. Implementation Phases

### Fase 1: Setup, Database & Responsive Shell
1. Inisialisasi proyek Flutter dan instalasi semua *dependencies* (`riverpod`, `drift`, `go_router`, `freezed`, dll).
2. Buat skema database Drift di `core/database/` dan jalankan `build_runner` untuk men-generate kode database.
3. Setup `GoRouter` dan bangun `MainShellLayout` menggunakan `NavigationRail` yang responsif untuk layar Desktop/Tablet (rasio 16:9 / 4:3).
4. Konfigurasi tema aplikasi (`AppTheme`) dan *helper* pemformatan mata uang Rupiah.

### Fase 2: Core UI & Mock Data
1. Bangun UI `CatalogScreen` (Tabel Produk & Kategori + Modal Form CRUD) menggunakan *stateless/mock data*.
2. Bangun UI `PosScreen` dengan *split-view* (Katalog Grid di kiri, Keranjang & Kalkulasi di kanan) beserta *Checkout Dialog*.
3. Bangun UI `OrdersScreen` (Grid status meja & daftar antrean pesanan) dan `ReportsScreen` (Tabel riwayat & kartu metrik).

### Fase 3: Logic, State Management & CRUD Integration
1. Buat DAO (*Data Access Objects*) di Drift dan integrasikan dengan Riverpod `AsyncNotifier` untuk fitur CRUD Kategori, Produk, dan Meja.
2. Buat `CartNotifier` di modul POS untuk mengelola state keranjang belanja (tambah item, ubah kuantitas, tambah catatan, hitung pajak/diskon/total).
3. Hubungkan aksi *Checkout* untuk menyimpan data ke tabel `Orders` dan `OrderItems` dalam satu transaksi database (*database transaction*), serta mengupdate status meja.
4. Hubungkan `OrdersScreen` dan `ReportsScreen` dengan *stream/future provider* dari database untuk menampilkan data transaksi secara *real-time*.

### Fase 4: Polish, Validation & Receipt Preview
1. Tambahkan validasi form pada CRUD Produk/Kategori dan proteksi penghapusan data (misal: cegah hapus kategori jika masih ada produk terkait).
2. Buat tampilan *Preview Struk* (Receipt Modal) setelah checkout berhasil atau saat melihat detail riwayat transaksi.
3. Optimasi UX kasir: tambahkan *keyboard shortcuts* dasar untuk Desktop (misal: `F1` fokus pencarian, `Enter` bayar) dan *loading/error states* yang bersih.
4. Buat fungsi *Database Seeder* untuk mengisi data awal (contoh kategori, menu F&B, dan daftar meja) saat aplikasi pertama kali dijalankan.