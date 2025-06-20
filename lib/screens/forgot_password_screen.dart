// forgot_password_screen.dart
import 'package:event_bnb/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

import '../services/dio_interceptor.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;
  bool showSuccess = false;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
        ..interceptors.add(AuthInterceptor(SessionManager().storage));

      final response = await dio.post('/api/auth/forgot-password', data: {
        "email": emailController.text.trim(),
      });

      if (response.statusCode == 200) {
        setState(() => showSuccess = true);
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) context.go('/reset-password');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Errore durante la richiesta';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => isLoading = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Password dimenticata")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Inserisci la tua email per ricevere il link di reset."),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _submit,
              child: const Text("Invia"),
            ),
            if (showSuccess)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  "Se l'email è registrata, riceverai un link per reimpostare la password.",
                  style: TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
