import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../auth/providers/auth_providers.dart';

class StaffManagementScreen extends ConsumerStatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  ConsumerState<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends ConsumerState<StaffManagementScreen> {
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  void _openAddEditUserModal([User? userToEdit]) {
    final nameController = TextEditingController(text: userToEdit?.name ?? '');
    final usernameController = TextEditingController(text: userToEdit?.username ?? '');
    final pinController = TextEditingController(text: userToEdit?.pin ?? '');
    String selectedRole = userToEdit?.role ?? 'cashier';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEditing = userToEdit != null;

            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    isEditing ? LucideIcons.userCheck : LucideIcons.userPlus,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Ubah Data Staf' : 'Tambah Staf Baru',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nama Lengkap *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Misal: Budi Santoso',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        const Text('Username / ID Staf *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Misal: budi_mgr',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),

                        const Text('Peran Hak Akses (RBAC) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedRole,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Admin (Akses Penuh Semua Modul)')),
                                DropdownMenuItem(value: 'manager', child: Text('Manager (Operasional & Otorisasi Void)')),
                                DropdownMenuItem(value: 'cashier', child: Text('Kasir (Transaksi & Riwayat Shift)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedRole = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text('6-Digit PIN Kasir *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: '6 angka PIN unik (misal: 111111)',
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length != 6 || int.tryParse(v) == null) {
                              return 'PIN harus tepat 6 digit angka!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final db = ref.read(databaseProvider);
                      if (isEditing) {
                        await db.updateUser(
                          userToEdit.copyWith(
                            name: nameController.text.trim(),
                            username: usernameController.text.trim(),
                            role: selectedRole,
                            pin: pinController.text.trim(),
                          ),
                        );
                      } else {
                        await db.insertUser(
                          UsersCompanion.insert(
                            name: nameController.text.trim(),
                            username: usernameController.text.trim(),
                            role: selectedRole,
                            pin: pinController.text.trim(),
                            avatarUrl: const drift.Value('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'),
                          ),
                        );
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? 'Data staf diperbarui!' : 'Staf baru berhasil ditambahkan!'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Staf'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onResetPin(User user) {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset PIN untuk ${user.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Masukkan 6-digit PIN baru untuk staf ini:'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'PIN Baru (6 angka)',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => (v == null || v.trim().length != 6) ? 'PIN harus 6 digit' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await ref.read(databaseProvider).updateUser(
                        user.copyWith(pin: pinController.text.trim()),
                      );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('PIN ${user.name} berhasil diubah!'),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan PIN'),
            ),
          ],
        );
      },
    );
  }

  void _onDeleteUser(User user) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak dapat menghapus akun Anda sendiri yang sedang aktif login!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Staf ${user.name}?'),
          content: Text('Apakah Anda yakin ingin menghapus akun ${user.name} (${user.role.toUpperCase()}) dari sistem?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                await ref.read(databaseProvider).deleteUser(user.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Staf ${user.name} telah dihapus.'),
                      backgroundColor: AppColors.onSurface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Hapus Akun'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Manajemen Staf & Hak Akses (RBAC)',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Kelola kredensial PIN, profil staf, dan peran wewenang operasional kasir.',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.userPlus, size: 18),
                  label: const Text('Tambah Staf Baru', style: TextStyle(fontWeight: FontWeight.w700)),
                  onPressed: () => _openAddEditUserModal(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Bar & Search
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  // Search
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau username staf...',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Role Filter Tabs
                  Row(
                    children: [
                      _buildFilterChip('Semua Peran', 'all'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Admin', 'admin'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Manager', 'manager'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Kasir', 'cashier'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Staff Table
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Gagal memuat staf: $e')),
                data: (users) {
                  final filtered = users.where((u) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        u.username.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesRole = _selectedRoleFilter == 'all' || u.role == _selectedRoleFilter;
                    return matchesSearch && matchesRole;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users, size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text('Tidak ada staf yang sesuai filter pencarian.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                            child: user.avatarUrl == null ? const Icon(LucideIcons.user, size: 20) : null,
                          ),
                          title: Row(
                            children: [
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(width: 8),
                              _buildRoleBadge(user.role),
                            ],
                          ),
                          subtitle: Text(
                            'ID: @${user.username}',
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant, fontFamily: 'monospace'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // PIN display & reset
                              Row(
                                children: [
                                  const Text('••••••', style: TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: () => _onResetPin(user),
                                    child: const Text('Reset PIN', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Active Toggle
                              Switch(
                                value: user.isActive,
                                activeColor: AppColors.secondary,
                                onChanged: (val) async {
                                  await ref.read(databaseProvider).updateUser(user.copyWith(isActive: val));
                                },
                              ),
                              const SizedBox(width: 8),

                              // Edit
                              IconButton(
                                icon: const Icon(LucideIcons.edit2, size: 18),
                                tooltip: 'Edit Staf',
                                onPressed: () => _openAddEditUserModal(user),
                              ),

                              // Delete
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error),
                                tooltip: 'Hapus Staf',
                                onPressed: () => _onDeleteUser(user),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRoleFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedRoleFilter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg;
    Color fg;
    String label;

    switch (role.toLowerCase()) {
      case 'admin':
        bg = AppColors.primaryContainer.withValues(alpha: 0.2);
        fg = AppColors.primary;
        label = 'Admin • Akses Penuh';
        break;
      case 'manager':
        bg = AppColors.secondaryContainer;
        fg = AppColors.onSecondaryContainer;
        label = 'Manager • Otorisasi Operasional';
        break;
      case 'cashier':
      default:
        bg = AppColors.surfaceContainerHighest;
        fg = AppColors.onSurfaceVariant;
        label = 'Kasir • Transaksi';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
