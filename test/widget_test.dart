import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnb_pos_app/core/database/app_database.dart';
import 'package:fnb_pos_app/features/catalog/widgets/product_form_drawer.dart';
import 'package:fnb_pos_app/features/pos/models/pos_models.dart';
import 'package:fnb_pos_app/features/pos/providers/pos_providers.dart';
import 'package:fnb_pos_app/features/pos/widgets/receipt_preview_dialog.dart';
import 'package:fnb_pos_app/main.dart';

void main() {
  testWidgets('App smoke test renders navigation and screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: FnbPosApp(),
      ),
    );

    expect(find.text('Pilih Staf Kasir'), findsOneWidget);
  });

  testWidgets('ReceiptPreviewDialog renders receipt details correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const testProduct = ProductModel(
      id: 1,
      categoryId: 1,
      categoryName: 'Kopi',
      name: 'Spanish Latte Macchiato',
      sku: 'KOP-001',
      price: 42000,
      imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c',
      stock: 10,
      isAvailable: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceiptPreviewDialog(
            orderNumber: '#ORD-999',
            orderType: 'Dine In',
            tableNumber: 'Meja 08',
            items: [
              CartItemModel(product: testProduct, quantity: 2),
            ],
            subtotal: 84000,
            tax: 9240,
            discount: 0,
            grandTotal: 93240,
            paymentMethod: 'QRIS',
            onClose: () {},
          ),
        ),
      ),
    );

    expect(find.text('Pembayaran Berhasil!'), findsOneWidget);
    expect(find.text('ARTISAN COFFEE & EATERY'), findsOneWidget);
    expect(find.text('Spanish Latte Macchiato'), findsOneWidget);
    expect(find.text('Cetak Ulang Struk'), findsOneWidget);
    expect(find.text('Selesai / Menu Baru'), findsOneWidget);
  });

  testWidgets('ProductFormDrawer enforces form validation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoriesStreamProvider.overrideWith(
            (ref) => Stream.value([
              const Category(
                id: 1,
                name: 'Kopi Spesialti',
                iconName: 'coffee',
                isActive: true,
              ),
            ]),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ProductFormDrawer(
              product: null,
              onSave: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Click Simpan while required name field is empty
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama menu wajib diisi'), findsOneWidget);
  });
}
