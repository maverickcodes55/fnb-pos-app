import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/pos_models.dart';

enum PaymentMethod {
  cash('Tunai', LucideIcons.banknote, 'Kembalian Otomatis'),
  qris('QRIS / E-Wallet', LucideIcons.qrCode, 'Layar Dinamis'),
  card('Debit / Kartu Kredit', LucideIcons.creditCard, 'Mesin EDC');

  final String label;
  final IconData icon;
  final String subtitle;
  const PaymentMethod(this.label, this.icon, this.subtitle);
}

class CheckoutModal extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final int totalAmount;
  final VoidCallback onPaymentSuccess;

  const CheckoutModal({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.onPaymentSuccess,
  });

  @override
  State<CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<CheckoutModal> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  String _cashInput = '';

  int get _cashAmount {
    if (_cashInput.isEmpty) return widget.totalAmount;
    return int.tryParse(_cashInput) ?? widget.totalAmount;
  }

  int get _changeAmount => (_cashAmount - widget.totalAmount).clamp(0, 999999999);

  void _onNumpadTap(String val) {
    setState(() {
      if (val == 'C') {
        _cashInput = '';
      } else if (val == '000') {
        if (_cashInput.isNotEmpty && _cashInput.length < 8) {
          _cashInput += '000';
        }
      } else {
        if (_cashInput.length < 9) {
          _cashInput += val;
        }
      }
    });
  }

  void _setPresetCash(int amount) {
    setState(() {
      _cashInput = amount.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 920,
        height: 640,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.wallet, color: AppColors.primary, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Pembayaran & Kasir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PROSES CEPAT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body Split
            Expanded(
              child: Row(
                children: [
                  // LEFT COLUMN: Recap (42%)
                  Container(
                    width: 380,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      border: Border(right: BorderSide(color: AppColors.divider)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 4, backgroundColor: AppColors.secondary),
                                      SizedBox(width: 6),
                                      Text(
                                        'Pesanan #ORD-204',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'MEJA 08',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kasir: Sarah K. • Shift #1 • 14:28 WIB',
                                style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'RINGKASAN PESANAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // List items
                        Expanded(
                          child: ListView.separated(
                            itemCount: widget.cartItems.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final item = widget.cartItems[index];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}×',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                          if (item.notes != null && item.notes!.isNotEmpty)
                                            Text(
                                              item.notes!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.subtotal),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Total box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOTAL TAGIHAN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: AppColors.onPrimaryFixed,
                                    ),
                                  ),
                                  Text(
                                    'Termasuk pajak & servis',
                                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              Text(
                                CurrencyFormatter.format(widget.totalAmount),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // RIGHT COLUMN: Payment execution (58%)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PILIH METODE PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Method Selection Cards
                          Row(
                            children: PaymentMethod.values.map((method) {
                              final isSelected = _selectedMethod == method;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedMethod = method),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary.withValues(alpha: 0.08)
                                            : AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : AppColors.divider,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            method.icon,
                                            size: 20,
                                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            method.label,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                              color: isSelected ? AppColors.primary : AppColors.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            method.subtitle,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          // Method Content
                          Expanded(
                            child: _selectedMethod == PaymentMethod.cash
                                ? _buildCashPaymentView()
                                : _selectedMethod == PaymentMethod.qris
                                    ? _buildQrisPaymentView()
                                    : _buildCardPaymentView(),
                          ),
                          const SizedBox(height: 12),
                          // Confirm CTA Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onPaymentSuccess();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.checkCheck, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Selesaikan Transaksi & Cetak Struk',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPaymentView() {
    return Column(
      children: [
        // Cash Input & Change Display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'UANG DITERIMA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
                  ),
                  Text(
                    CurrencyFormatter.format(_cashAmount),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Uang Kembalian:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSecondaryContainer),
                    ),
                    Text(
                      CurrencyFormatter.format(_changeAmount),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Quick Amount Chips
        Row(
          children: [
            Expanded(
              child: _buildQuickChip('Uang Pas', widget.totalAmount),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildQuickChip('Rp 100.000', 100000),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildQuickChip('Rp 200.000', 200000),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildQuickChip('Rp 250.000', 250000),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Numpad Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 1; i <= 9; i++) _buildNumpadBtn('$i'),
              _buildNumpadBtn('C', isAction: true),
              _buildNumpadBtn('0'),
              _buildNumpadBtn('000'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, int amount) {
    return InkWell(
      onTap: () => _setPresetCash(amount),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadBtn(String text, {bool isAction = false}) {
    return InkWell(
      onTap: () => _onNumpadTap(text),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          color: isAction ? AppColors.errorContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isAction ? AppColors.onErrorContainer : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrisPaymentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 2),
            ),
            child: const Icon(LucideIcons.qrCode, size: 120, color: AppColors.onSurface),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pindai QRIS Dinamis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Gunakan GoPay, OVO, BCA, atau m-banking lainnya',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPaymentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(LucideIcons.creditCard, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan Kartu ke Mesin EDC',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Terminal EDC Station 01 aktif. Menunggu tap/insert kartu...',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
