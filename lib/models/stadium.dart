class Stadium {
  int? id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String? ownerId;
  final double pricePerHour;
  final int capacity;

  Stadium({
    this.id,
    required this.name,
    required this.location,
    required this.description,
    this.imageUrl = 'assets/default_stadium.jpg',
    this.ownerId,
    this.pricePerHour = 50.0,
    this.capacity = 100,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'pricePerHour': pricePerHour,
      'capacity': capacity,
    };
  }

  factory Stadium.fromMap(Map<String, dynamic> map) {
    return Stadium(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      description: map['description'],
      imageUrl: map['imageUrl'] ?? 'assets/default_stadium.jpg',
      ownerId: map['ownerId'],
      pricePerHour: (map['pricePerHour'] ?? 50.0).toDouble(),
      capacity: map['capacity'] ?? 100,
    );
  }
}