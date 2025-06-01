class Stadium {
  int? id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final String? ownerId;

  Stadium({
    this.id,
    required this.name,
    required this.location,
    required this.description,
    this.imageUrl = 'assets/default_stadium.jpg',
    this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }

  factory Stadium.fromMap(Map<String, dynamic> map) {
    return Stadium(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      ownerId: map['ownerId'],
    );
  }
}