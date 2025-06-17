import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/dio_interceptor.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';
import 'package:dio/dio.dart';

import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final session = SessionManager();
  late final EventApi eventApi;
  List<EventModel> events = [];
  bool isLoading = true;
  String role = '';

  @override
  void initState() {
    super.initState();
    eventApi = EventApi(
      Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
        ..interceptors.add(AuthInterceptor(session.storage)),
    );
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final userRole = await session.getUserRole() ?? 'user';
    setState(() => role = userRole);

    try {
      final list = (userRole == 'user')
          ? await eventApi.getPublicEvents()
          : await eventApi.getMyEvents();

      setState(() {
        events = list;
        isLoading = false;
      });
    } catch (e) {
      print('Errore caricamento eventi: $e');
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'user' ? 'Eventi Pubblici' : 'I Miei Eventi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await session.clear();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          return EventCard(
            event: e,
            onTap: () {
              print('Evento selezionato: ${e.id}');
              context.go('/event/${e.id}');
            },
          );
        },
      ),

    );
  }
}
