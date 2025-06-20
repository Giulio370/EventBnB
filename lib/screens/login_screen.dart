import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = AuthApi();

  bool isLoading = false;

  void showErrorOverlay(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () => entry.remove());
  }

  Future<void> handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    setState(() => isLoading = true);

    try {
      await api.login(email, password);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      final data = e.response?.data;

      String msg;
      if (data is String) {
        msg = data;
      } else if (data is Map && data['message'] is String) {
        msg = data['message'];
      } else {
        msg = 'Errore di accesso';
      }

      if (msg.toLowerCase().contains('verifica')) {
        context.go('/verify-email', extra: {
          'email': email,
          'password': password,
        });
      } else {
        showErrorOverlay(msg);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              child: isLoading ? const Text('Caricamento...') : const Text('Login'),
            ),
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: const Text('Password dimenticata?'),
            ),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: const Text('Non hai un account? Registrati'),
            )
          ],
        ),
      ),
    );
  }
}
