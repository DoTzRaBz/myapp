import 'package:myapp/models/user.dart';

class AuthProvider {
  static User? currentUser;

  static void login(User user) {
    currentUser = user;
  }

  static void logout() {
    currentUser = null;
  }

  static String get currentUserName => 
    currentUser?.email ?? 'Pengguna Umum';

  static bool get isLoggedIn => currentUser != null;

  static bool get isAdminOrStaff => 
    currentUser?.isAdminOrStaff ?? false;
}