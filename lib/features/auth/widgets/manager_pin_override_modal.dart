import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../providers/auth_providers.dart';

class ManagerPinOverrideModal extends ConsumerStatefulWidget {
  final String actionTitle;
  final String actionDescription;

  const ManagerPinOverrideModal({
    super.key,
    required this.actionTitle,
    required this.actionDescription,
  });

  static Future<User?> show(BuildContext context, {
    required String actionTitle,
    required String actionDescription,
  }) {
    return showDialog<User>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ManagerPinOverrideModal(
        actionTitle: actionTitle,
        actionDescription: actionDescription,
      ),
    );
  }

  @override
  ConsumerState<ManagerPinOverrideModal> createState() => _ManagerPinOverrideModalState();
}

class _ManagerPinOverrideModalState extends ConsumerState<ManagerPinOverrideModal> {
  String _pin = '';
  String? _errorMessage;
  bool _isValidating = false;

  void _onDigit(String digit) {
    if (_pin.length < 6 && !_isValidating) {
      setState(() {
        _errorMessage = null;
        _pin += digit;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _backspace() {
    if (_pin.isNotEmpty && !_isValidating) {
      setState(() {
        _errorMessage = null;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _clear() {
    if (!_isValidating) {
      setState(() {
        _errorMessage = null;
        _pin = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isValidating = true);
    try {
      final manager = await ref.read(authControllerProvider).verifyManagerOrAdminPin(_pin);
      if (mounted) {
        if (manager != null) {
          Navigator.pop(context, manager);
        } else {
          setState(() {
            _isValidating = false;
            _errorMessage = 'PIN Manager/Admin salah! Akses ditolak.';
            _pin = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _errorMessage = 'Error validasi: $e';
          _pin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 380,
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.shieldAlert, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Otorisasi Manager / Admin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                        Text(
                          'Hak Akses Khusus Diperlukan',
                          style: TextStyle(fontSize: 11, color: AppColors.onErrorContainer),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    color: AppColors.onErrorContainer,
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
                  Text(
                    widget.actionTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.actionDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // 6 PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      final isFilled = index < _pin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled ? AppColors.primary : AppColors.surfaceContainerHighest,
                          border: Border.all(
                            color: isFilled ? AppColors.primary : AppColors.divider,
                            width: 1.5,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Keypad
                  SizedBox(
                    height: 220,
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.7,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (var i = 1; i <= 9; i++)
                          _buildKeyBtn('$i', () => _onDigit('$i')),
                        _buildActionBtn('C', _clear),
                        _buildKeyBtn('0', () => _onDigit('0')),
                        _buildActionBtn('⌫', _backspace),
                      ],
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

  Widget _buildKeyBtn(String digit, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
