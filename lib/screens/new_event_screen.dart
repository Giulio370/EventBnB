import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_interceptor.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final categoryController = TextEditingController();
  final priceController = TextEditingController();
  final maxParticipantsController = TextEditingController();
  DateTime? selectedDate;
  File? coverImage;
  List<File> galleryImages = [];
  late EventApi eventApi;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    eventApi = EventApi(Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage)));
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => coverImage = File(picked.path));
  }

  Future<void> _pickGalleryImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => galleryImages.add(File(picked.path)));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    setState(() => isSubmitting = true);

    final eventData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "date": selectedDate!.toUtc().toIso8601String(),
      "location": {
        "city": cityController.text,
        "address": addressController.text,
        "type": "Point"
      },
      "category": categoryController.text,
      "price": int.tryParse(priceController.text) ?? 0,
      "maxParticipants": int.tryParse(maxParticipantsController.text) ?? 0,
    };

    final newEvent = await eventApi.createEvent(eventData);

    if (coverImage != null) {
      await eventApi.uploadCover(newEvent.id, coverImage!);
    }
    for (final img in galleryImages) {
      await eventApi.uploadImage(newEvent.id, img);
    }

    if (context.mounted) {
      setState(() => isSubmitting = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Crea nuovo evento')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Titolo'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrizione'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Indirizzo'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'Città'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Prezzo'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  TextFormField(
                    controller: maxParticipantsController,
                    decoration: const InputDecoration(labelText: 'Max Partecipanti'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Campo obbligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Data:'),
                      const SizedBox(width: 10),
                      Text(selectedDate != null ? selectedDate!.toLocal().toString().split(' ')[0] : 'Non selezionata'),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Cover image'),
                  const SizedBox(height: 4),
                  if (coverImage != null)
                    Image.file(coverImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ElevatedButton.icon(
                    onPressed: _pickCoverImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Scegli copertina'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Galleria immagini'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: galleryImages.map((file) => Image.file(file, width: 100, height: 100, fit: BoxFit.cover)).toList(),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickGalleryImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Aggiungi immagine'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _submitEvent,
                    icon: const Icon(Icons.save),
                    label: const Text('Crea evento'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
