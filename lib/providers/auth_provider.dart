import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String? phoneNumber,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
        phoneNumber,
      );
      return user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (_user != null) {
      await _authService.updateUserProfile(_user!.id, data);
    }
  }
  // Debug method to reset database
  Future<void> resetDatabase() async {
    final dbHelper = _authService.dbHelper;
    await dbHelper.resetDatabase();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }
}
