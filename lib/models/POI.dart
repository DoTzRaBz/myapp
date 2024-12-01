// models/POI.dart
class PointOfInterest {
  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
    };
  }
}