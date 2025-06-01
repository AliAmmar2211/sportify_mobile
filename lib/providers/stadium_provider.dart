import 'package:flutter/material.dart';
import 'package:sportify_mobile/data/database_helper.dart';
import 'package:sportify_mobile/models/stadium.dart';
import 'package:sportify_mobile/models/booking.dart';

class StadiumProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Stadium> _stadiums = [];
  List<Booking> _bookings = [];

  List<Stadium> get stadiums => _stadiums;
  List<Booking> get bookings => _bookings;

  Future<void> loadStadiums() async {
    _stadiums = await _dbHelper.getStadiums();
    notifyListeners();
  }

  Future<void> addStadium(Stadium stadium, String? ownerId) async {
    final stadiumWithOwner = Stadium(
      id: stadium.id,
      name: stadium.name,
      location: stadium.location,
      description: stadium.description,
      imageUrl: stadium.imageUrl,
    );
      if (stadium.id == null) {
      await _dbHelper.insertStadium(stadiumWithOwner);
    } else {
      await _dbHelper.updateStadium(stadiumWithOwner);
    }
    await loadStadiums();
  }

  Future<void> bookStadium(Booking booking) async {
    await _dbHelper.insertBooking(booking);
    await loadBookings(booking.stadiumId);
  }

  Future<void> loadBookings(int stadiumId) async {
    _bookings = await _dbHelper.getBookingsForStadium(stadiumId);
    notifyListeners();
  }
}