import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/event_api.dart';
import '../services/dio_interceptor.dart';
import '../session/session_manager.dart';
import 'edit_event_screen.dart';

class EventDetailOrganizerScreen extends StatefulWidget {
  final String eventId;

  const EventDetailOrganizerScreen({super.key, required this.eventId});

  @override
  State<EventDetailOrganizerScreen> createState() => _EventDetailOrganizerScreenState();
}

class _EventDetailOrganizerScreenState extends State<EventDetailOrganizerScreen> {
  late EventApi eventApi;
  EventModel? event;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    eventApi = EventApi(Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage)));
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final result = await eventApi.getEventById(widget.eventId);
      setState(() {
        event = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<Widget> _buildActionButtons() {
    if (event == null) return [];

    switch (event!.status) {
      case 'draft':
        return [
          ElevatedButton(
            onPressed: () async {
              await eventApi.publishEvent(widget.eventId);
              await fetchEventDetails();
            },
            child: const Text('Pubblica'),
          ),
          ElevatedButton(
            onPressed: () async {
              await eventApi.deleteEvent(widget.eventId);
              if (context.mounted) context.go('/home');
            },
            child: const Text('Elimina'),
          ),
        ];

      case 'published':
        return [
          ElevatedButton(
            onPressed: () async {
              await eventApi.cancelEvent(widget.eventId);
              await fetchEventDetails();
            },
            child: const Text('Annulla'),
          ),
        ];

      case 'cancelled':
        return []; // Nessun bottone

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Event Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/home');
            },
          ),
          actions: [
            if (event != null && event!.status != 'cancelled')
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditEventScreen(event: event!),
                    ),
                  ).then((_) => fetchEventDetails());
                },
              ),
          ],
        ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
          ? const Center(child: Text('Evento non trovato'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event!.coverImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    event!.coverImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                  ),
                ),
              const SizedBox(height: 12),
              Text(event!.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              if (event!.description != null)
                Text(event!.description!),
              const SizedBox(height: 16),
              Text('Data: ${event!.date.toLocal()}'),
              Text('Luogo: ${event!.address}, ${event!.city}'),
              if (event!.category != null)
                Text('Categoria: ${event!.category}'),
              if (event!.price != null)
                Text('Prezzo: €${event!.price!.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Text('Stato: ${event!.status}'),
              const SizedBox(height: 16),
              if (event!.images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Galleria immagini:'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: event!.images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event!.images[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                children: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
