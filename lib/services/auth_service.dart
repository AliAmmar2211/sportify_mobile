import 'dart:async';
import '../models/user.dart';
import '../data/database_helper.dart';

class AuthService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  User? _currentUser;

  // Get current user
  User? get currentUser => _currentUser;

  // Get database helper for testing
  DatabaseHelper get dbHelper => _dbHelper;

  // Auth state changes stream
  Stream<User?> get user => _userController.stream;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _dbHelper.signInUser(email, password);
      if (user != null) {
        _currentUser = user;
        _userController.add(user);
      }
      return user;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }
  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    String? phoneNumber,
  ) async {
    try {
      print('Attempting to register user: $email');
      final user = await _dbHelper.createUser(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
        role: UserRole.user,
      );
      
      if (user != null) {
        print('User registered successfully: ${user.id}');
        _currentUser = user;
        _userController.add(user);
      } else {
        print('User registration failed - email already exists: $email');
      }
      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _currentUser = null;
      _userController.add(null);
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Get current user profile
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final user = await _dbHelper.getUserById(userId);
      if (user != null) {
        final updatedUser = User(
          id: user.id,
          email: data['email'] ?? user.email,
          name: data['name'] ?? user.name,
          phoneNumber: data['phoneNumber'] ?? user.phoneNumber,
          role: user.role,
          ownedStadiums: user.ownedStadiums,
          bookings: user.bookings,
        );
        
        await _dbHelper.updateUser(updatedUser);
        _currentUser = updatedUser;
        _userController.add(updatedUser);
      }
    } catch (e) {
      print('Update profile error: $e');
      throw e;
    }
  }
  void dispose() {
    _userController.close();
  }

  // Debug/Testing methods
  Future<void> clearAllUsers() async {
    await _dbHelper.clearAllUsers();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _dbHelper.getAllUsers();
  }
}
