import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final void Function()? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasImage = event.coverImage != null && event.coverImage!.isNotEmpty;
    final image = hasImage
        ? NetworkImage(event.coverImage!)
        : const AssetImage('assets/placeholder.jpg'); // oppure usa un emoji

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.go('/event/${event.id}');
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine
            SizedBox(
              height: 160,
              width: double.infinity,
              child: hasImage
                  ? Image.network(event.coverImage!, fit: BoxFit.cover)
                  : Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Text(
                  '🎫',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('${event.city}, ${event.address}'),
                  const SizedBox(height: 4),
                  Text(
                    '📅 ${event.date.toLocal().toString().substring(0, 16)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Chip(label: Text(event.status.toUpperCase())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
