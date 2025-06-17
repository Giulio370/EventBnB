import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../services/auth_api.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final api = AuthApi();
  bool isLoading = false;

  void showOverlay(String message, {bool error = false}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: error ? Colors.red.shade600 : Colors.green.shade600,
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

  Future<void> retryLogin() async {
    setState(() => isLoading = true);

    try {
      await api.login(widget.email, widget.password);
      if (!mounted) return;
      context.go('/home');
    } on DioException catch (e) {
      final data = e.response?.data;
      print("🔍 response.data: ${e.response?.data}");

      String msg;
      if (data is String) {
        msg = data;
      } else if (data is Map && data['message'] is String) {
        msg = data['message'];
      } else {
        msg = 'Errore di accesso';
      }

      showOverlay(msg, error: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> resendVerification() async {
    try {
      await api.resendVerification(widget.email);
      showOverlay("Email di verifica inviata!");
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Errore nel rinvio';
      showOverlay(msg, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conferma email')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📧 Verifica il tuo indirizzo email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Abbiamo inviato un link di verifica a ${widget.email}. Dopo aver cliccato il link, premi il pulsante sotto per accedere automaticamente.',
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: isLoading ? const Text('Controllo in corso...') : const Text('Ho confermato'),
              onPressed: isLoading ? null : retryLogin,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: resendVerification,
              child: const Text('Rimanda la mail di verifica'),
            ),
          ],
        ),
      ),
    );
  }
}
