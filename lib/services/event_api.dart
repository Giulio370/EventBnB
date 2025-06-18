import 'package:dio/dio.dart';
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
