import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../services/dio_interceptor.dart';
import '../services/event_api.dart';
import '../session/session_manager.dart';

class EditEventScreen extends StatefulWidget {
  EventModel event;

  EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController maxParticipantsController;
  DateTime? selectedDate;
  late EventApi eventApi;
  late EventModel currentEvent;

  @override
  void initState() {
    super.initState();
    final session = SessionManager();
    eventApi = EventApi(Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!))
      ..interceptors.add(AuthInterceptor(session.storage)));

    currentEvent = widget.event;
    titleController = TextEditingController(text: currentEvent.title);
    descriptionController = TextEditingController(text: currentEvent.description);
    addressController = TextEditingController(text: currentEvent.address);
    cityController = TextEditingController(text: currentEvent.city);
    categoryController = TextEditingController(text: currentEvent.category);
    priceController = TextEditingController(text: currentEvent.price?.toString() ?? '');
    maxParticipantsController = TextEditingController(text: currentEvent.maxParticipants?.toString() ?? '');
    selectedDate = currentEvent.date;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    cityController.dispose();
    categoryController.dispose();
    priceController.dispose();
    maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _saveChanges() async {
    final updatedData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "date": selectedDate!.toUtc().toIso8601String(),
      "location": {
        "city": cityController.text,
        "address": addressController.text,
      },
      "category": categoryController.text,
      "price": int.tryParse(priceController.text) ?? 0,
      "maxParticipants": int.tryParse(maxParticipantsController.text) ?? 0,
    };

    await eventApi.updateEvent(currentEvent.id, updatedData);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _deleteImage(String imageUrl) async {
    await eventApi.deleteImage(currentEvent.id, imageUrl);
    await _refreshEvent();
  }

  Future<void> _uploadCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await eventApi.uploadCover(currentEvent.id, File(picked.path));
      await _refreshEvent();
    }
  }

  Future<void> _uploadCarouselImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await eventApi.uploadImage(currentEvent.id, File(picked.path));
      await _refreshEvent();
    }
  }

  Future<void> _refreshEvent() async {
    final updated = await eventApi.getEventById(currentEvent.id);
    setState(() => currentEvent = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifica Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copertina', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (currentEvent.coverImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  currentEvent.coverImage!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 4),
            ElevatedButton.icon(
              onPressed: _uploadCoverImage,
              icon: const Icon(Icons.upload),
              label: const Text('Aggiorna immagine copertina'),
            ),
            const SizedBox(height: 20),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titolo')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descrizione')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Indirizzo')),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Città')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoria')),
            TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Prezzo'), keyboardType: TextInputType.number),
            TextField(controller: maxParticipantsController, decoration: const InputDecoration(labelText: 'Max Partecipanti'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
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
            const Text('Galleria immagini', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (currentEvent.images.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: currentEvent.images.map((url) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _deleteImage(url),
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 14,
                            child: Icon(Icons.delete, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _uploadCarouselImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Aggiungi immagine'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Salva modifiche'),
            )
          ],
        ),
      ),
    );
  }
}
