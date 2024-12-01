class Event {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime date;

  Event({
    required this.title, 
    required this.description, 
    this.imageUrl, 
    required this.date
  });

  // Factory constructor untuk membuat Event dari Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      description: map['description'],
      imageUrl: map['image_url'],
      date: DateTime.parse(map['date']),
    );
  }

  // Metode untuk mengkonversi Event ke Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'date': date.toIso8601String(),
    };
  }
}