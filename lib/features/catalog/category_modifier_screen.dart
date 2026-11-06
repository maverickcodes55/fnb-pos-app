import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/currency_formatter.dart';
import '../pos/providers/pos_providers.dart';

final modifierGroupsStreamProvider = StreamProvider<List<ModifierGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchModifierGroups();
});

final allModifierOptionsStreamProvider = StreamProvider<List<ModifierOption>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllModifierOptions();
});

class CategoryModifierScreen extends ConsumerStatefulWidget {
  const CategoryModifierScreen({super.key});

  @override
  ConsumerState<CategoryModifierScreen> createState() => _CategoryModifierScreenState();
}

class _CategoryModifierScreenState extends ConsumerState<CategoryModifierScreen> {
  void _openAddEditCategoryModal([Category? categoryToEdit]) {
    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    String selectedIcon = categoryToEdit?.iconName ?? 'coffee';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEditing = categoryToEdit != null;

            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEditing ? 'Ubah Kategori' : 'Tambah Kategori Baru'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nama Kategori *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Mocktail & Jus Segar',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama kategori wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    const Text('Pilihan Ikon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['coffee', 'croissant', 'soup', 'glass-water', 'ice-cream'].map((iconKey) {
                        final isSel = selectedIcon == iconKey;
                        return ChoiceChip(
                          label: Text(iconKey),
                          selected: isSel,
                          selectedColor: AppColors.primaryContainer,
                          onSelected: (_) => setModalState(() => selectedIcon = iconKey),
                        );
                      }).toList(),
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
                      final db = ref.read(databaseProvider);
                      if (isEditing) {
                        await db.updateCategory(categoryToEdit.copyWith(
                          name: nameController.text.trim(),
                          iconName: selectedIcon,
                        ));
                      } else {
                        await db.insertCategory(CategoriesCompanion.insert(
                          name: nameController.text.trim(),
                          iconName: drift.Value(selectedIcon),
                        ));
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? 'Kategori diperbarui!' : 'Kategori berhasil ditambahkan!'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Simpan' : 'Tambah Kategori'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openAddEditGroupModal([ModifierGroup? groupToEdit]) {
    final nameController = TextEditingController(text: groupToEdit?.name ?? '');
    bool isRequired = groupToEdit?.isRequired ?? false;
    int minSelect = groupToEdit?.minSelect ?? 0;
    int maxSelect = groupToEdit?.maxSelect ?? 1;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isEditing = groupToEdit != null;

            return AlertDialog(
              backgroundColor: AppColors.surfaceContainerLowest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEditing ? 'Ubah Grup Modifikasi' : 'Buat Grup Modifikasi Baru'),
              content: SizedBox(
                width: 440,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Grup Modifikasi *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Misal: Level Gula / Pilihan Susu',
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama grup wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        title: const Text('Wajib Dipilih di POS?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        subtitle: const Text('Kasir harus memilih opsi ini sebelum masuk ke keranjang', style: TextStyle(fontSize: 11)),
                        value: isRequired,
                        activeColor: AppColors.secondary,
                        onChanged: (val) {
                          setModalState(() {
                            isRequired = val;
                            if (val && minSelect == 0) minSelect = 1;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Min. Pilihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<int>(
                                  value: minSelect,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLow,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: [0, 1, 2].map((i) => DropdownMenuItem(value: i, child: Text('$i'))).toList(),
                                  onChanged: (val) => setModalState(() => minSelect = val ?? 0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Maks. Pilihan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<int>(
                                  value: maxSelect,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.surfaceContainerLow,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: [1, 2, 3, 5, 10].map((i) => DropdownMenuItem(value: i, child: Text('$i'))).toList(),
                                  onChanged: (val) => setModalState(() => maxSelect = val ?? 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final db = ref.read(databaseProvider);
                      if (isEditing) {
                        await db.updateModifierGroup(groupToEdit.copyWith(
                          name: nameController.text.trim(),
                          isRequired: isRequired,
                          minSelect: minSelect,
                          maxSelect: maxSelect,
                        ));
                      } else {
                        await db.insertModifierGroup(ModifierGroupsCompanion.insert(
                          name: nameController.text.trim(),
                          isRequired: drift.Value(isRequired),
                          minSelect: drift.Value(minSelect),
                          maxSelect: drift.Value(maxSelect),
                        ));
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? 'Grup modifikasi diperbarui!' : 'Grup modifikasi berhasil dibuat!'),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Simpan' : 'Buat Grup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openAddEditOptionModal(int groupId, [ModifierOption? optionToEdit]) {
    final nameController = TextEditingController(text: optionToEdit?.name ?? '');
    final priceController = TextEditingController(text: optionToEdit != null ? '${optionToEdit.extraPrice}' : '0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final isEditing = optionToEdit != null;
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          title: Text(isEditing ? 'Ubah Opsi Modifikasi' : 'Tambah Opsi Pilihan'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Opsi *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Misal: Oat Milk Barista Edition',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama opsi wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                const Text('Biaya Tambahan (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixText: 'Rp ',
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
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
                  final db = ref.read(databaseProvider);
                  final extraPrice = int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                  if (isEditing) {
                    await db.updateModifierOption(optionToEdit.copyWith(
                      name: nameController.text.trim(),
                      extraPrice: extraPrice,
                    ));
                  } else {
                    await db.insertModifierOption(ModifierOptionsCompanion.insert(
                      groupId: groupId,
                      name: nameController.text.trim(),
                      extraPrice: drift.Value(extraPrice),
                    ));
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'Simpan' : 'Tambah Opsi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final groupsAsync = ref.watch(modifierGroupsStreamProvider);
    final optionsAsync = ref.watch(allModifierOptionsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Breadcrumb & Status
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
                          'Matriks Kategori & Modifikasi Menu',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Kelola hierarki kategori F&B dan opsi modifikasi (level gula, jenis susu, topping).',
                      style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.checkCheck, size: 14, color: AppColors.secondary),
                      SizedBox(width: 4),
                      Text(
                        'Sinkronisasi Reaktif SQLite',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2-Column Split Workspace (50% / 50%)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Categories Management
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kategori Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                  Text('Daftar tab kategori di layar kasir POS', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                icon: const Icon(LucideIcons.folderPlus, size: 16),
                                label: const Text('Kategori Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                onPressed: () => _openAddEditCategoryModal(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: categoriesAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, s) => Center(child: Text('Gagal: $e')),
                              data: (cats) {
                                if (cats.isEmpty) {
                                  return const Center(child: Text('Belum ada kategori.'));
                                }
                                return ListView.separated(
                                  itemCount: cats.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final cat = cats[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                                        child: const Icon(LucideIcons.coffee, size: 18, color: AppColors.primary),
                                      ),
                                      title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      subtitle: Text(
                                        cat.isActive ? 'Aktif di POS' : 'Nonaktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: cat.isActive ? AppColors.secondary : AppColors.error,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Switch(
                                            value: cat.isActive,
                                            activeColor: AppColors.secondary,
                                            onChanged: (val) async {
                                              await ref.read(databaseProvider).updateCategory(cat.copyWith(isActive: val));
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.edit2, size: 16),
                                            onPressed: () => _openAddEditCategoryModal(cat),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                                            onPressed: () async {
                                              await ref.read(databaseProvider).deleteCategory(cat.id);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // RIGHT COLUMN: Modifiers & Add-ons CRUD
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Modifikasi & Tambahan (Add-ons)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                  Text('Grup kustomisasi untuk varian menu F&B', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                icon: const Icon(LucideIcons.listPlus, size: 16),
                                label: const Text('Buat Grup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                onPressed: () => _openAddEditGroupModal(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: groupsAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, s) => Center(child: Text('Gagal: $e')),
                              data: (groups) {
                                if (groups.isEmpty) {
                                  return const Center(child: Text('Belum ada grup modifikasi.'));
                                }

                                final allOptions = optionsAsync.value ?? [];

                                return ListView.separated(
                                  itemCount: groups.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final group = groups[index];
                                    final groupOptions = allOptions.where((o) => o.groupId == group.id).toList();

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.divider),
                                      ),
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        leading: Icon(
                                          group.isRequired ? LucideIcons.checkSquare : LucideIcons.square,
                                          color: group.isRequired ? AppColors.secondary : AppColors.onSurfaceVariant,
                                          size: 18,
                                        ),
                                        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                        subtitle: Text(
                                          group.isRequired
                                              ? 'WAJIB • Pilih min. ${group.minSelect}, maks. ${group.maxSelect}'
                                              : 'OPSIONAL • Maks. ${group.maxSelect}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: group.isRequired ? AppColors.secondary : AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(LucideIcons.plusCircle, size: 16, color: AppColors.primary),
                                              tooltip: 'Tambah Opsi',
                                              onPressed: () => _openAddEditOptionModal(group.id),
                                            ),
                                            IconButton(
                                              icon: const Icon(LucideIcons.edit2, size: 16),
                                              tooltip: 'Edit Grup',
                                              onPressed: () => _openAddEditGroupModal(group),
                                            ),
                                            IconButton(
                                              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                                              tooltip: 'Hapus Grup',
                                              onPressed: () async {
                                                await ref.read(databaseProvider).deleteModifierGroup(group.id);
                                              },
                                            ),
                                          ],
                                        ),
                                        children: [
                                          if (groupOptions.isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: Text('Belum ada opsi. Klik tombol (+) untuk menambah.', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                            )
                                          else
                                            ...groupOptions.map((opt) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: const BoxDecoration(
                                                    border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(opt.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            opt.extraPrice > 0 ? '+${CurrencyFormatter.format(opt.extraPrice)}' : 'Gratis / Normal',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.w700,
                                                              color: opt.extraPrice > 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          IconButton(
                                                            icon: const Icon(LucideIcons.trash, size: 14, color: AppColors.error),
                                                            onPressed: () async {
                                                              await ref.read(databaseProvider).deleteModifierOption(opt.id);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
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
}
