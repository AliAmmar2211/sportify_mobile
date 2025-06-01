class Booking {
  int? id;
  final int stadiumId;
  final String? userId;
  final String date;
  final String timeSlot;
  final String userName;

  Booking({
    this.id,
    required this.stadiumId,
    this.userId,
    required this.date,
    required this.timeSlot,
    required this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stadiumId': stadiumId,
      'userId': userId,
      'date': date,
      'timeSlot': timeSlot,
      'userName': userName,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      stadiumId: map['stadiumId'],
      userId: map['userId'],
      date: map['date'],
      timeSlot: map['timeSlot'],
      userName: map['userName'],
    );
  }
}