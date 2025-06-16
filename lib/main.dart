import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router.dart';

Future<void> main() async {
  await dotenv.load(fileName: "assets/.env");
  print("BASE URL: ${dotenv.env['API_BASE_URL']}");
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Event App',
      routerConfig: router,
    );
  }
}
