import 'package:flutter/material.dart';
import 'package:sportify_mobile/data/database_helper.dart';
import 'package:sportify_mobile/models/stadium.dart';
import 'package:sportify_mobile/models/booking.dart';
// import 'package:sportify_mobile/providers/auth_provider.dart';

class StadiumProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Stadium> _stadiums = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Stadium> get stadiums => _stadiums;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadStadiums() async {
    _isLoading = true;
    notifyListeners();

    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('stadiums');
    
    _stadiums = List.generate(maps.length, (i) {
      return Stadium.fromMap(maps[i]);
    });
    _isLoading = false;
    notifyListeners();
  }

  Future<List<Stadium>> getMyStadiums(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'stadiums',
      where: 'ownerId = ?',
      whereArgs: [userId],
    );
    
    return List.generate(maps.length, (i) {
      return Stadium.fromMap(maps[i]);
    });
  }
  Future<void> addStadium(Stadium stadium) async {
    await _dbHelper.insertStadium(stadium);
    await loadStadiums();
  }

  Future<void> updateStadium(Stadium stadium) async {
    await _dbHelper.updateStadium(stadium);
    await loadStadiums();
  }
  
  Future<void> loadBookings(int stadiumId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'stadiumId = ?',
      whereArgs: [stadiumId],
    );
    
    _bookings = List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> loadAllUserBookings(String userId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    _bookings = List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
    notifyListeners();
  }

  Future<void> bookStadium(Booking booking) async {
    await _dbHelper.insertBooking(booking);
    await loadBookings(booking.stadiumId);
  }

}