import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_interceptor.dart';
import '../session/session_manager.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? message;

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      message = null;
    });

    try {
      final dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
        ..interceptors.add(AuthInterceptor(SessionManager().storage));

      final response = await dio.post('/api/auth/reset-password', data: {
        'email': emailController.text.trim(),
        'token': tokenController.text.trim(),
        'newPassword': passwordController.text,
      });

      setState(() => message = response.data['message']);
      await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) context.go('/login');
    } on DioException catch (e) {
      setState(() {
        message = e.response?.data['message'] ?? 'Errore durante il reset';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(labelText: 'Token ricevuto via email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nuova password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : resetPassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text("Resetta password"),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(message!,
                  style: TextStyle(
                    color: message!.contains("successo") ? Colors.green : Colors.red,
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
