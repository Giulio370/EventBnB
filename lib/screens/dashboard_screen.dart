import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_interceptor.dart';
import '../session/session_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Dio dio;
  bool isLoading = true;
  Map<String, dynamic>? dashboardData;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage));
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      final response = await dio.get('/api/events/organizer/dashboard');
      setState(() {
        dashboardData = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget buildCard(String title, dynamic value, {Color? color, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            (color ?? Theme.of(context).primaryColor).withOpacity(0.9),
            (color ?? Theme.of(context).primaryColor).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? Icons.bar_chart, size: 36, color: Colors.white),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardData == null
          ? const Center(child: Text('Errore nel caricamento'))
          : GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          buildCard('Totale Eventi', dashboardData!['totalEvents'], color: Colors.blue, icon: Icons.event),
          buildCard('Eventi Pubblicati', dashboardData!['publishedEvents'], color: Colors.green, icon: Icons.check_circle),
          buildCard('Eventi in Bozza', dashboardData!['draftEvents'], color: Colors.orange, icon: Icons.edit),
          buildCard('Eventi Annullati', dashboardData!['canceledEvents'], color: Colors.red, icon: Icons.cancel),
          buildCard('Prenotazioni Totali', dashboardData!['totalBookings'], color: Colors.purple, icon: Icons.people),
          buildCard('Occupazione Media', '${dashboardData!['averageOccupancy']}%', color: Colors.teal, icon: Icons.insert_chart),
        ],
      ),
    );
  }
}
