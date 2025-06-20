// Nuova schermata con tab per Preferiti e Prenotati
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';
import '../services/dio_interceptor.dart';
import 'package:dio/dio.dart';
import '../widgets/event_card.dart';
import 'package:go_router/go_router.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late final EventApi eventApi;
  late TabController _tabController;
  List<EventModel> favorites = [];
  List<BookingModel> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    eventApi = EventApi(
      Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
        ..interceptors.add(AuthInterceptor(session.storage)),
    );
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final favs = await eventApi.getUserFavorites();
      final bookedRes = await eventApi.getUserBookings();
      setState(() {
        favorites = favs;
        bookings = bookedRes;
        isLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento eventi personali: $e');
      setState(() => isLoading = false);
    }
  }

  String getDateBadge(DateTime target) {
    final now = DateTime.now();
    final diff = target.difference(now);
    if (diff.inDays < 0) return 'Evento passato';
    if (diff.inDays < 30) return 'Tra ${diff.inDays} giorni';
    final months = (diff.inDays / 30).floor();
    return 'Tra $months mese${months > 1 ? 'i' : ''}';
  }

  Widget buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(booking.title),
        subtitle: Text('${booking.address}, ${booking.city}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(getDateBadge(booking.date)),
        ),
        onTap: () {
          context.go('/event/${booking.eventId}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("I miei eventi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // ritorna alla home dell'utente base
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Preferiti'),
            Tab(icon: Icon(Icons.event_available), text: 'Prenotati'),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) => EventCard(
              event: favorites[index],
              onTap: () => context.go('/event/${favorites[index].id}'),
            ),
          ),
          ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) =>
                buildBookingCard(bookings[index]),
          )
        ],
      ),
    );
  }
}
