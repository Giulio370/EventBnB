import 'dart:io';

import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/event_model.dart';
import '../session/session_manager.dart';

class EventApi {
  final Dio _dio;

  EventApi(this._dio);

  Future<List<EventModel>> getPublicEvents() async {
    final response = await _dio.get('/api/events');
    final List data = response.data;
    return data.map((json) => EventModel.fromJson(json)).toList();
  }
  Future<EventModel> getEventById(String id) async {
    final response = await _dio.get('/api/events/$id');
    return EventModel.fromJson(response.data);
  }
  Future<void> addToFavorites(String eventId) async {
    await _dio.post('/api/events/$eventId/favorite');
  }

  Future<void> removeFromFavorites(String eventId) async {
    await _dio.delete('/api/events/$eventId/favorite');
  }

  Future<void> bookEvent(String eventId) async {
    await _dio.post('/api/events/$eventId/book');
  }

  Future<void> cancelBooking(String eventId) async {
    await _dio.delete('/api/events/$eventId/book');
  }



  Future<void> publishEvent(String id) async {
    await _dio.patch('/api/events/$id/publish');
  }

  Future<void> cancelEvent(String id) async {
    await _dio.patch('/api/events/$id/cancel');
  }

  Future<void> deleteEvent(String id) async {
    await _dio.delete('/api/events/$id');
  }

  Future<void> uploadCover(String id, File image) async {
    final formData = FormData.fromMap({
      'cover': await MultipartFile.fromFile(image.path),
    });
    await _dio.patch('/api/events/$id/cover', data: formData);
  }

  Future<void> uploadImage(String id, File image) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
    });
    await _dio.patch('/api/events/$id/images', data: formData);
  }

  Future<void> deleteImage(String id, String imageUrl) async {
    await _dio.delete(
      '/api/events/$id/images',
      data: {'imageUrl': imageUrl},
    );
  }

  Future<void> updateEvent(String id, Map<String, dynamic> updatedData) async {
    await _dio.put('/api/events/$id', data: updatedData);
  }

  Future<EventModel> createEvent(Map<String, dynamic> eventData) async {
    final response = await _dio.post('/api/events', data: eventData);
    return EventModel.fromJson(response.data['event']);
  }

  Future<List<EventModel>> getUserFavorites() async {
    final response = await _dio.get('/api/me/favorites');
    final List data = response.data;

    // Estrai `event` da ogni item prima di fare il parsing
    return data
        .map((json) => EventModel.fromJson(json['event']))
        .toList();
  }



  Future<List<BookingModel>> getUserBookings() async {
    final response = await _dio.get('/api/events/me/bookings');
    final List data = response.data;
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }






  Future<List<EventModel>> getMyEvents() async {
    final session = SessionManager();
    final accessToken = await session.accessToken;
    final refreshToken = await session.refreshToken;

    final response = await _dio.get(
      '/api/events/my-events',
      options: Options(
        headers: {
          'cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
        },
      ),
    );

    final List data = response.data;
    return data.map((json) => EventModel.fromJson(json)).toList();
  }

}
