import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../services/dio_interceptor.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';

class EventDetailUserScreen extends StatefulWidget {
  final String eventId;

  const EventDetailUserScreen({super.key, required this.eventId});

  @override
  State<EventDetailUserScreen> createState() => _EventDetailUserScreenState();
}

class _EventDetailUserScreenState extends State<EventDetailUserScreen> {
  EventModel? event;
  bool isLoading = true;
  bool isFavorite = false;
  late final Dio dio;



  @override
  void initState() {
    super.initState();

    final session = SessionManager();
    dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage));

    _loadEvent();
  }


  Future<void> _loadEvent() async {
    try {
      final session = SessionManager();

      final dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
        ..interceptors.add(AuthInterceptor(session.storage));

      final data = await EventApi(dio).getEventById(widget.eventId);

      setState(() {
        event = data;
        isFavorite = data.isFavorite;
        isLoading = false;
      });

    } catch (e) {
      print('Errore caricamento evento: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (event == null) {
      return const Scaffold(body: Center(child: Text('Evento non trovato')));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
      SliverAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        expandedHeight: 240,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
        title: Text(
          event!.title,
          style: const TextStyle(
            color: Colors.white,
            shadows: [Shadow(offset: Offset(0, 0), blurRadius: 4, color: Colors.black)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
          // Cover Image
          Image.network(event!.coverImage!, fit: BoxFit.cover),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),

          // Heart Button
          Positioned(
            top: 36,
            right: 16,
            child: IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.redAccent,
              size: 30,
            ),
                onPressed: () async {
                  try {
                    if (isFavorite) {
                      await EventApi(dio).removeFromFavorites(event!.id);
                    } else {
                      await EventApi(dio).addToFavorites(event!.id);
                    }

                    setState(() => isFavorite = !isFavorite);
                  } catch (e) {
                    print('Errore aggiornamento preferiti: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Errore durante l\'aggiornamento dei preferiti')),
                    );
                  }
                },

            ),
          ),
          ],
        ),
      ),
    ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location & Date
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 6),
                      Text('${event!.city}, ${event!.address}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 6),
                      Text('${event!.date.toLocal().toString().substring(0, 16)}'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Categoria & Prezzo
                  if (event!.category != null)
                    Row(children: [const Icon(Icons.category), const SizedBox(width: 6), Text('Categoria: ${event!.category}')]),
                  if (event!.price != null)
                    Row(children: [const Icon(Icons.attach_money), const SizedBox(width: 6), Text('Prezzo: €${event!.price}')]),

                  const SizedBox(height: 20),

                  // Carosello immagini
                  if (event!.images.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📷 Galleria', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: event!.images.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  event!.images[index],
                                  width: 280,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Descrizione
                  if (event!.description != null) ...[
                    const Text('📝 Descrizione', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(event!.description!),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(event!.isBooked ? Icons.cancel : Icons.check_circle),
                      label: Text(event!.isBooked ? 'Annulla prenotazione' : 'Prenota evento'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event!.isBooked ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        try {
                          if (event!.isBooked) {
                            await EventApi(dio).cancelBooking(event!.id);
                          } else {
                            await EventApi(dio).bookEvent(event!.id);
                          }

                          // aggiorna evento
                          final updated = await EventApi(dio).getEventById(event!.id);
                          setState(() => event = updated);
                        } catch (e) {
                          print('❌ Errore prenotazione: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Errore durante ${event!.isBooked ? "l\'annullamento" : "la prenotazione"}')),
                          );
                        }
                      },
                    ),
                  ),

                ],

              ),
            ),
          )
        ],
      ),
    );
  }

}
