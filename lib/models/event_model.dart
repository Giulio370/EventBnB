class EventModel {
  final String id;
  final String title;
  final String address;
  final String city;
  final DateTime date;
  final String status;
  final String? coverImage;
  final String? description;
  final String? category;
  final int? price;
  final List<String> images;
  final bool isFavorite;
  final bool isBooked;


  EventModel({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.date,
    required this.status,
    this.coverImage,
    this.description,
    this.category,
    this.price,
    required this.images,
    required this.isFavorite,
    required this.isBooked,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'],
      title: json['title'],
      address: json['location']['address'],
      city: json['location']['city'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      coverImage: json['coverImage'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      images: List<String>.from(json['images'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      isBooked: json['isBooked'] ?? false,

    );
  }
}
