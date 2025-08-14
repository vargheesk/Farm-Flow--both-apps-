import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementDetailPage extends StatelessWidget {
  final Map<String, dynamic> announcement;
  final String announcementId;

  const AnnouncementDetailPage({
    super.key,
    required this.announcement,
    required this.announcementId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['heading'] ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            if (announcement['imageLink'] != null &&
                announcement['imageLink'].toString().isNotEmpty)
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  announcement['imageLink'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(announcement['summary'] ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(announcement['description'] ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (announcement['helplineNumber'] != null &&
                announcement['helplineNumber'].toString().isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Helpline'),
                  subtitle: Text(announcement['helplineNumber']),
                ),
              ),
            const SizedBox(height: 8),
            if (announcement['link'] != null &&
                announcement['link'].toString().isNotEmpty)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Related Link'),
                  subtitle: Text(announcement['link']),
                ),
              ),
            const SizedBox(height: 8),
            if (announcement['lastDate'] != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Last Date'),
                  subtitle: Text(
                    DateTime.parse(announcement['lastDate'])
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('State: ${announcement['state']}'),
                    Text('District: ${announcement['district']}'),
                    Text('Block: ${announcement['block']}'),
                    Text('Office: ${announcement['office']}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
