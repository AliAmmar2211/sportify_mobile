class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final List<String> ownedStadiums;
  final List<String> bookings;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.ownedStadiums = const [],
    this.bookings = const [],
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'ownedStadiums': ownedStadiums.join(','),
      'bookings': bookings.join(','),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      ownedStadiums: map['ownedStadiums'] != null && map['ownedStadiums'].isNotEmpty 
          ? (map['ownedStadiums'] as String).split(',') 
          : [],
      bookings: map['bookings'] != null && map['bookings'].isNotEmpty 
          ? (map['bookings'] as String).split(',') 
          : [],
    );
  }
}
