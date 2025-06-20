class BookingModel {
  final String eventId;
  final String title;
  final DateTime date;
  final String city;
  final String address;
  final String category;
  final String status;
  final DateTime bookingDate;

  BookingModel({
    required this.eventId,
    required this.title,
    required this.date,
    required this.city,
    required this.address,
    required this.category,
    required this.status,
    required this.bookingDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      eventId: json['eventId'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      city: json['city'],
      address: json['address'],
      category: json['category'],
      status: json['status'],
      bookingDate: DateTime.parse(json['bookingDate']),
    );
  }
}
