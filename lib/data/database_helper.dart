import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/stadium.dart';
import '../models/booking.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // In-memory storage for web platform
  static List<Map<String, dynamic>> _webUsers = [];
  static List<Map<String, dynamic>> _webStadiums = [];
  static List<Map<String, dynamic>> _webBookings = [];
  static int _nextStadiumId = 1;
  static int _nextBookingId = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      // For web platform, we'll use in-memory lists
      // Return a mock database object
      throw UnimplementedError('Database not supported on web, using in-memory storage');
    }
    
    if (_database != null) return _database!;
    _database = await _initDB('stadium_booking.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Clear existing data and recreate tables
          await db.execute('DROP TABLE IF EXISTS users');
          await db.execute('DROP TABLE IF EXISTS bookings');
          await db.execute('DROP TABLE IF EXISTS stadiums');
          await _createDB(db, newVersion);
        }
      },
    );
  }  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phoneNumber TEXT,
        role TEXT NOT NULL,
        ownedStadiums TEXT,
        bookings TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE stadiums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT,
        ownerId TEXT,
        FOREIGN KEY (ownerId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stadiumId INTEGER NOT NULL,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        timeSlot TEXT NOT NULL,
        userName TEXT NOT NULL,
        FOREIGN KEY (stadiumId) REFERENCES stadiums (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Insert sample stadiums
    await db.insert('stadiums', {
      'name': 'Central Sports Arena',
      'location': 'Downtown Sports Complex',
      'description': 'Modern indoor arena with professional lighting and sound system',
      'imageUrl': 'assets/default_stadium.jpg',
      'ownerId': null,
    });

    await db.insert('stadiums', {
      'name': 'Green Valley Stadium',
      'location': 'Green Valley Park',
      'description': 'Beautiful outdoor stadium surrounded by nature',
      'imageUrl': 'assets/default_stadium.jpg',
      'ownerId': null,
    });

    await db.insert('stadiums', {
      'name': 'City Football Ground',
      'location': 'City Center',
      'description': 'Premium football stadium with VIP facilities',
      'imageUrl': 'assets/default_stadium.jpg',
      'ownerId': null,
    });
  }

  // Stadium operations
  Future<int> insertStadium(Stadium stadium) async {
    final db = await instance.database;
    return await db.insert('stadiums', stadium.toMap());
  }

  Future<List<Stadium>> getStadiums() async {
    final db = await instance.database;
    final maps = await db.query('stadiums');
    return maps.map((map) => Stadium.fromMap(map)).toList();
  }

  // Booking operations
  Future<int> insertBooking(Booking booking) async {
    final db = await instance.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<int> updateStadium(Stadium stadium) async {
  final db = await instance.database;
  return await db.update(
    'stadiums',
    stadium.toMap(),
    where: 'id = ?',
    whereArgs: [stadium.id],
  );
}
  Future<List<Booking>> getBookingsForStadium(int stadiumId) async {
    final db = await instance.database;
    final maps = await db.query(
      'bookings',
      where: 'stadiumId = ?',
      whereArgs: [stadiumId],
    );
    return maps.map((map) => Booking.fromMap(map)).toList();
  }

  // User operations
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> generateUserId() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return 'user_$timestamp';
  }
  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    UserRole role = UserRole.user,
  }) async {
    try {
      final db = await instance.database;
      
      print('DEBUG: Attempting to create user with email: $email');
      
      // Check if user already exists
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      
      print('DEBUG: Existing users with this email: ${existingUser.length}');
      
      if (existingUser.isNotEmpty) {
        print('DEBUG: User already exists with email: $email');
        return null; // User already exists
      }
      
      final userId = await generateUserId();
      final hashedPassword = _hashPassword(password);
      
      final user = User(
        id: userId,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        role: role,
      );
      
      final userMap = user.toMap();
      userMap['password'] = hashedPassword;
      
      print('DEBUG: Inserting user: $userMap');
      
      await db.insert('users', userMap);
      
      print('DEBUG: User created successfully with ID: $userId');
      return user;
    } catch (e) {
      print('DEBUG: Error creating user: $e');
      return null;
    }
  }

  Future<User?> signInUser(String email, String password) async {
    final db = await instance.database;
    final hashedPassword = _hashPassword(password);
    
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String userId) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Debug/Testing methods
  Future<void> clearAllUsers() async {
    final db = await instance.database;
    await db.delete('users');
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users');
  }

  // Complete database reset for debugging
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stadium_booking.db');
    
    // Close current database connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete the database file
    await deleteDatabase(path);
    
    // Reinitialize the database
    _database = await _initDB('stadium_booking.db');
  }
}