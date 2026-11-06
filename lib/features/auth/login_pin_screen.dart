import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import 'providers/auth_providers.dart';
import 'widgets/open_shift_modal.dart';

class LoginPinScreen extends ConsumerStatefulWidget {
  const LoginPinScreen({super.key});

  @override
  ConsumerState<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends ConsumerState<LoginPinScreen> {
  User? _selectedUser;
  String _pin = '';
  String? _errorMessage;
  bool _isLoading = false;

  void _onSelectUser(User user) {
    setState(() {
      _selectedUser = user;
      _pin = '';
      _errorMessage = null;
    });
  }

  void _onDigit(String digit) {
    if (_pin.length < 6 && !_isLoading && _selectedUser != null) {
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
    if (_pin.isNotEmpty && !_isLoading) {
      setState(() {
        _errorMessage = null;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _clearPin() {
    if (!_isLoading) {
      setState(() {
        _errorMessage = null;
        _pin = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_selectedUser == null) return;
    setState(() => _isLoading = true);

    try {
      final user = await ref.read(authControllerProvider).login(_selectedUser!.id, _pin);
      if (!mounted) return;

      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'PIN salah! Silakan coba lagi.';
          _pin = '';
        });
        return;
      }

      // Check active shift
      final activeShift = await ref.read(shiftControllerProvider).getActiveShift();
      if (!mounted) return;

      if (activeShift == null) {
        // Must open shift first
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OpenShiftModal(
            user: user,
            onShiftOpened: () {
              if (mounted) context.go('/pos');
            },
          ),
        );
      } else {
        context.go('/pos');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal verifikasi PIN: $e';
          _pin = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListStreamProvider);
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('EEEE, d MMM yyyy').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top Header Bar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
              border: const Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.utensilsCrossed, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WarmBite POS Terminal #01',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Front of House • Bar Utama',
                          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.wifi, size: 12, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text(
                            'Online Database',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main 2-Column Auth Screen
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1180, maxHeight: 680),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 18,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // LEFT COLUMN: Staff Directory
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pilih Staf Kasir',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Pilih Profil Staf',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Pilih profil Anda untuk login kasir atau otorisasi hak akses.',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),

                            // Staff Grid
                            Expanded(
                              child: usersAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, s) => Center(child: Text('Gagal memuat staf: $e')),
                                data: (users) {
                                  if (users.isEmpty) {
                                    return const Center(child: Text('Tidak ada staf aktif.'));
                                  }

                                  // Auto-select first user if none selected
                                  if (_selectedUser == null && users.isNotEmpty) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (mounted) _onSelectUser(users.first);
                                    });
                                  }

                                  return GridView.builder(
                                    itemCount: users.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2.2,
                                    ),
                                    itemBuilder: (context, index) {
                                      final user = users[index];
                                      final isSelected = _selectedUser?.id == user.id;

                                      return InkWell(
                                        onTap: () => _onSelectUser(user),
                                        borderRadius: BorderRadius.circular(12),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 150),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryContainer.withValues(alpha: 0.15)
                                                : AppColors.surfaceContainerLowest,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected ? AppColors.primary : AppColors.divider,
                                              width: isSelected ? 2 : 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.15),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Row(
                                            children: [
                                              // Avatar with active check
                                              Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor: AppColors.surfaceContainerHigh,
                                                    backgroundImage: user.avatarUrl != null
                                                        ? NetworkImage(user.avatarUrl!)
                                                        : null,
                                                    child: user.avatarUrl == null
                                                        ? const Icon(LucideIcons.user, size: 20)
                                                        : null,
                                                  ),
                                                  if (isSelected)
                                                    Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 16,
                                                        height: 16,
                                                        decoration: const BoxDecoration(
                                                          color: AppColors.primary,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(LucideIcons.check, size: 10, color: Colors.white),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    _buildRolePill(user.role),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              children: [
                                Icon(LucideIcons.info, size: 14, color: AppColors.onSurfaceVariant),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Default PIN: Admin: 111111 | Manager: 222222 | Cashier: 333333',
                                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // RIGHT COLUMN: PIN Keypad & Shift Float Warning
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Staff Greeting
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  backgroundImage: _selectedUser?.avatarUrl != null
                                      ? NetworkImage(_selectedUser!.avatarUrl!)
                                      : null,
                                  child: _selectedUser?.avatarUrl == null
                                      ? const Icon(LucideIcons.user, size: 28)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedUser != null
                                      ? 'Selamat Datang, ${_selectedUser!.name}'
                                      : 'Pilih Akun Staf',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedUser != null
                                      ? '${_selectedUser!.role.toUpperCase()} • Masukkan 6 Digit PIN Otorisasi'
                                      : 'Pilih salah satu staf di panel kiri',
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(height: 14),

                                // 6 PIN Dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(6, (index) {
                                    final isFilled = index < _pin.length;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
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
                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error),
                                    ),
                                  ),
                              ],
                            ),

                            // Numeric Tactile Keypad
                            Container(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.7,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (var i = 1; i <= 9; i++)
                                    _buildKeypadBtn('$i', () => _onDigit('$i')),
                                  _buildKeypadBtn('C', _clearPin, isAction: true),
                                  _buildKeypadBtn('0', () => _onDigit('0')),
                                  _buildKeypadBtn('⌫', _backspace, isAction: true),
                                ],
                              ),
                            ),

                            // Shift Opener Advisory Card
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryFixed.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.tertiaryFixedDim),
                              ),
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.wallet, size: 18, color: AppColors.tertiary),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Shift Baru: Anda akan diminta memasukkan modal kas awal jika shift belum dibuka.',
                                      style: TextStyle(fontSize: 11, color: AppColors.onTertiaryFixedVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePill(String role) {
    Color bg;
    Color fg;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
        bg = AppColors.primaryContainer.withValues(alpha: 0.2);
        fg = AppColors.primary;
        label = 'Admin';
        break;
      case 'manager':
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        label = 'Manager';
        break;
      case 'cashier':
      default:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceVariant;
        label = 'Kasir';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildKeypadBtn(String label, VoidCallback onTap, {bool isAction = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isAction ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isAction ? 16 : 20,
              fontWeight: FontWeight.w800,
              color: isAction ? AppColors.onSurfaceVariant : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
