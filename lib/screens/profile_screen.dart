import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../services/dio_interceptor.dart';
import '../session/session_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Dio dio;
  bool isLoading = true;
  Map<String, dynamic>? userData;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  File? newProfileImage;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage));
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final response = await dio.get('/api/auth/me');
      setState(() {
        userData = response.data;
        nameController.text = response.data['name'] ?? '';
        descriptionController.text = response.data['description'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
    final data = {
      'name': nameController.text,
      'description': descriptionController.text,
    };

    try {
      await dio.patch('/api/auth/me', data: data);
      // if (newProfileImage != null) {
      //   final formData = FormData.fromMap({
      //     'profileImage': await MultipartFile.fromFile(newProfileImage!.path),
      //   });
      //   await dio.patch('/api/auth/me/profile-image', data: formData);
      // }
      fetchUser();
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Successo'),
            content: const Text('Profilo aggiornato con successo!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Errore aggiornamento profilo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore durante il salvataggio del profilo')),
      );
    }
  }

  Future<void> pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newProfileImage = File(picked.path));
    }
  }

  Widget buildProfileImage(Map<String, dynamic> user) {
    final url = user['profileImageUrl'];
    final bool isValidUrl = url != null && url.toString().startsWith('http');

    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey[300],
      backgroundImage: isValidUrl ? NetworkImage(url) : null,
      child: !isValidUrl ? const Icon(Icons.person, size: 40, color: Colors.white70) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo Utente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final session = SessionManager();
            final role = await session.getUserRole();
            if (context.mounted) {
              context.go('/home');
            }
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text('Errore nel caricamento'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  buildProfileImage(userData!),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickNewImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Email: ${userData!['email']}'),
            Text('Ruolo: ${userData!['role']}'),
            Text('Verificato: ${userData!['verified'] ? 'Sì' : 'No'}'),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: updateProfile,
              icon: const Icon(Icons.save),
              label: const Text('Salva modifiche'),
            )
          ],
        ),
      ),
    );
  }
}