import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAnnouncementForm extends StatefulWidget {
  const AdminAnnouncementForm({super.key});

  @override
  State<AdminAnnouncementForm> createState() => _AdminAnnouncementFormState();
}

class _AdminAnnouncementFormState extends State<AdminAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _headingController = TextEditingController();
  final _summaryController = TextEditingController();
  final _imageLinkController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _helplineController = TextEditingController();
  final _linkController = TextEditingController();
  final _lastDateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _headingController.dispose();
    _summaryController.dispose();
    _imageLinkController.dispose();
    _descriptionController.dispose();
    _helplineController.dispose();
    _linkController.dispose();
    _lastDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _lastDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitAnnouncement() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create global announcement document
      await _firestore.collection('GlobalAnnouncements').add({
        'heading': _headingController.text,
        'summary': _summaryController.text,
        'imageLink': _imageLinkController.text,
        'description': _descriptionController.text,
        'helplineNumber': _helplineController.text,
        'link': _linkController.text,
        'lastDate': _selectedDate?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastEdited': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
        'isGlobal': true,
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Global announcement created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Create an announcement visible to all users regardless of location hierarchy',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _headingController,
              decoration: InputDecoration(
                labelText: 'Heading',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.title),
                hintText: 'Enter the main announcement title',
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Heading is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.short_text),
                hintText: 'Brief summary of the announcement',
              ),
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Summary is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageLinkController,
              decoration: InputDecoration(
                labelText: 'Image Link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.image),
                hintText: 'https://example.com/image.jpg',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.description),
                hintText: 'Detailed description of the announcement',
              ),
              maxLines: 6,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Description is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _helplineController,
              decoration: InputDecoration(
                labelText: 'Helpline Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.phone),
                hintText: 'Contact number for inquiries',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: 'Link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.link),
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastDateController,
              decoration: InputDecoration(
                labelText: 'Last Date (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'DD/MM/YYYY',
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitAnnouncement,
                icon: _isSubmitting
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Submit Announcement'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.indigo.withOpacity(0.5),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Add padding at the bottom for keyboard safe area
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 32),
          ],
        ),
      ),
    );
  }
}