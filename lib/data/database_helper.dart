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
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
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
        ownedStadiums TEXT,
        bookings TEXT
      )
    ''');await db.execute('''
      CREATE TABLE stadiums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        imageUrl TEXT,
        ownerId TEXT,
        pricePerHour REAL DEFAULT 50.0,
        capacity INTEGER DEFAULT 100,
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
    try {
      if (kIsWeb) {
        // Web implementation using in-memory storage
        final stadiumMap = stadium.toMap();
        stadiumMap['id'] = _nextStadiumId++;
        _webStadiums.add(stadiumMap);
        return stadiumMap['id'];
      }
      
      final db = await instance.database;
      return await db.insert('stadiums', stadium.toMap());
    } catch (e) {
      print('Error inserting stadium: $e');
      rethrow;
    }
  }

  Future<int> updateStadium(Stadium stadium) async {
    try {
      if (kIsWeb) {
        // Web implementation using in-memory storage
        final index = _webStadiums.indexWhere((s) => s['id'] == stadium.id);
        if (index != -1) {
          _webStadiums[index] = stadium.toMap();
          return 1;
        }
        return 0;
      }
      
      final db = await instance.database;
      return await db.update(
        'stadiums',
        stadium.toMap(),
        where: 'id = ?',
        whereArgs: [stadium.id],
      );
    } catch (e) {
      print('Error updating stadium: $e');
      rethrow;
    }
  }

  Future<void> deleteStadium(int stadiumId) async {
    try {
      if (kIsWeb) {
        _webStadiums.removeWhere((s) => s['id'] == stadiumId);
        return;
      }
      
      final db = await instance.database;
      await db.delete(
        'stadiums',
        where: 'id = ?',
        whereArgs: [stadiumId],
      );
    } catch (e) {
      print('Error deleting stadium: $e');
      rethrow;
    }
  }

  Future<Stadium?> getStadiumById(int stadiumId) async {
    try {
      if (kIsWeb) {
        final stadium = _webStadiums.firstWhere(
          (s) => s['id'] == stadiumId,
          orElse: () => <String, dynamic>{},
        );
        return stadium.isNotEmpty ? Stadium.fromMap(stadium) : null;
      }
      
      final db = await instance.database;
      final maps = await db.query(
        'stadiums',
        where: 'id = ?',
        whereArgs: [stadiumId],
      );
      
      if (maps.isNotEmpty) {
        return Stadium.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting stadium by id: $e');
      return null;
    }
  }

  Future<List<Stadium>> getAllStadiums() async {
    try {
      if (kIsWeb) {
        return _webStadiums.map((s) => Stadium.fromMap(s)).toList();
      }
      
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query('stadiums');
      return maps.map((map) => Stadium.fromMap(map)).toList();
    } catch (e) {
      print('Error getting all stadiums: $e');
      return [];
    }
  }

  // Booking operations
  Future<int> insertBooking(Booking booking) async {
    try {
      if (kIsWeb) {
        final bookingMap = booking.toMap();
        bookingMap['id'] = _nextBookingId++;
        _webBookings.add(bookingMap);
        return bookingMap['id'];
      }
      
      final db = await instance.database;
      return await db.insert('bookings', booking.toMap());
    } catch (e) {
      print('Error inserting booking: $e');
      rethrow;
    }
  }

  Future<List<Booking>> getBookingsByStadium(int stadiumId) async {
    try {
      if (kIsWeb) {
        return _webBookings
            .where((b) => b['stadiumId'] == stadiumId)
            .map((b) => Booking.fromMap(b))
            .toList();
      }
      
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'stadiumId = ?',
        whereArgs: [stadiumId],
      );
      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      print('Error getting bookings by stadium: $e');
      return [];
    }
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    try {
      if (kIsWeb) {
        return _webBookings
            .where((b) => b['userId'] == userId)
            .map((b) => Booking.fromMap(b))
            .toList();
      }
      
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'bookings',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return maps.map((map) => Booking.fromMap(map)).toList();
    } catch (e) {
      print('Error getting bookings by user: $e');
      return [];
    }
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
  }  Future<User?> createUser({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
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