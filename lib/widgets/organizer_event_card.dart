import 'package:flutter/material.dart';
import '../models/event_model.dart';

class OrganizerEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const OrganizerEventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.coverImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                child: Image.network(
                  event.coverImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${event.address}, ${event.city}'),
                    const SizedBox(height: 4),
                    Text('${event.date.toLocal()}'),
                    const SizedBox(height: 4),
                    Text('Stato: ${event.status}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}