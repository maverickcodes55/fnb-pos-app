import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier() : super(null);

  void setUser(User? user) {
    state = user;
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier();
});

final usersListStreamProvider = StreamProvider<List<User>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchUsers();
});

final activeShiftStreamProvider = StreamProvider<Shift?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchActiveShift();
});

class AuthController {
  final AppDatabase db;
  final Ref ref;

  AuthController(this.db, this.ref);

  Future<User?> login(int userId, String pin) async {
    final user = await db.authenticateByPin(userId, pin);
    if (user != null) {
      ref.read(currentUserProvider.notifier).setUser(user);
    }
    return user;
  }

  void logout() {
    ref.read(currentUserProvider.notifier).setUser(null);
  }

  Future<User?> verifyManagerOrAdminPin(String pin) async {
    return await db.verifyManagerOrAdminPin(pin);
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  final db = ref.watch(databaseProvider);
  return AuthController(db, ref);
});

class ShiftController {
  final AppDatabase db;

  ShiftController(this.db);

  Future<int> openShift({required int userId, required int startingCash}) {
    return db.openShift(userId: userId, startingCash: startingCash);
  }

  Future<void> closeShift({required int shiftId, required int actualCash}) {
    return db.closeShift(shiftId: shiftId, actualCash: actualCash);
  }

  Future<Shift?> getActiveShift() {
    return db.getActiveShift();
  }
}

final shiftControllerProvider = Provider<ShiftController>((ref) {
  final db = ref.watch(databaseProvider);
  return ShiftController(db);
});

