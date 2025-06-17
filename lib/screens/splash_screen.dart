import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../session/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final session = SessionManager();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {

    final access = await session.accessToken;
    print('📦 Access Token letto: $access');

    final loggedIn = await session.isLoggedIn();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    context.go(loggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
