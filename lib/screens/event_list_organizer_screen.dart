import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/event_model.dart';
import '../services/dio_interceptor.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';
import 'event_detail_organizer_screen.dart';
import 'new_event_screen.dart';

class EventListOrganizerScreen extends StatefulWidget {
  const EventListOrganizerScreen({super.key});

  @override
  State<EventListOrganizerScreen> createState() => _EventListOrganizerScreenState();
}

class _EventListOrganizerScreenState extends State<EventListOrganizerScreen> {
  List<EventModel> events = [];
  bool isLoading = true;
  late final Dio dio;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage));

    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    try {
      final result = await EventApi(dio).getMyEvents();
      setState(() {
        events = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // gestisci errore con snackbar o altro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewEventScreen()),
              );
              fetchMyEvents();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text('${event.date.toLocal()}\n${event.address}, ${event.city}'),
            isThreeLine: true,
            trailing: Text(event.status ?? 'draft'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailOrganizerScreen(eventId: event.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
