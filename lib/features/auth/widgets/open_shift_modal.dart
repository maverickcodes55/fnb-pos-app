import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/auth_providers.dart';

class OpenShiftModal extends ConsumerStatefulWidget {
  final User user;
  final VoidCallback onShiftOpened;

  const OpenShiftModal({
    super.key,
    required this.user,
    required this.onShiftOpened,
  });

  @override
  ConsumerState<OpenShiftModal> createState() => _OpenShiftModalState();
}

class _OpenShiftModalState extends ConsumerState<OpenShiftModal> {
  String _cashInput = '500000';
  bool _isLoading = false;

  int get _startingCash => int.tryParse(_cashInput) ?? 0;

  void _onKeypadTap(String val) {
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

  void _backspace() {
    if (_cashInput.isNotEmpty) {
      setState(() {
        _cashInput = _cashInput.substring(0, _cashInput.length - 1);
      });
    }
  }

  Future<void> _submitOpenShift() async {
    if (_startingCash <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modal kas awal wajib diisi minimal Rp 1!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(shiftControllerProvider).openShift(
            userId: widget.user.id,
            startingCash: _startingCash,
          );
      if (mounted) {
        Navigator.pop(context);
        widget.onShiftOpened();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka shift: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.wallet, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buka Shift Kasir Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Kasir: ${widget.user.name} • Stasiun 01',
                          style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Advisory Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.tertiaryFixedDim),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.info, size: 18, color: AppColors.tertiary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Masukkan jumlah uang fisik di laci kasir (starting cash float) sebelum memulai shift transaksi.',
                            style: TextStyle(fontSize: 12, color: AppColors.onTertiaryFixedVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display Amount
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MODAL KAS AWAL (STARTING FLOAT)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(_startingCash),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Chips
                  Row(
                    children: [
                      _buildQuickChip('Rp 200.000', 200000),
                      const SizedBox(width: 6),
                      _buildQuickChip('Rp 500.000', 500000),
                      const SizedBox(width: 6),
                      _buildQuickChip('Rp 1.000.000', 1000000),
                      const SizedBox(width: 6),
                      _buildQuickChip('Rp 1.500.000', 1500000),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Numeric Keypad
                  SizedBox(
                    height: 180,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var i = 1; i <= 9; i++) _buildKeypadBtn('$i'),
                        _buildActionBtn('C', () => _onKeypadTap('C')),
                        _buildKeypadBtn('0'),
                        _buildActionBtn('⌫', _backspace),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit CTA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _submitOpenShift,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.checkCheck, size: 20),
                      label: Text(
                        _isLoading ? 'Membuka Shift...' : 'Buka Shift & Masuk ke POS',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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

  Widget _buildQuickChip(String label, int amount) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _cashInput = amount.toString()),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadBtn(String digit) {
    return InkWell(
      onTap: () => _onKeypadTap(digit),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

