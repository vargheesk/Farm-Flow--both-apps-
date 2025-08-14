// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AnnouncementForm extends StatefulWidget {
//   const AnnouncementForm({super.key});

//   @override
//   State<AnnouncementForm> createState() => _AnnouncementFormState();
// }

// class _AnnouncementFormState extends State<AnnouncementForm> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final _headingController = TextEditingController();
//   final _summaryController = TextEditingController();
//   final _imageLinkController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _helplineController = TextEditingController();
//   final _linkController = TextEditingController();
//   final _lastDateController = TextEditingController();
//   DateTime? _selectedDate;

//   @override
//   void dispose() {
//     _headingController.dispose();
//     _summaryController.dispose();
//     _imageLinkController.dispose();
//     _descriptionController.dispose();
//     _helplineController.dispose();
//     _linkController.dispose();
//     _lastDateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//         _lastDateController.text =
//             "${picked.day}/${picked.month}/${picked.year}";
//       });
//     }
//   }

//   Future<void> _submitAnnouncement() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;

//       // Get user data to access location details
//       final userDoc = await _firestore.collection('Users').doc(user.uid).get();
//       final userData = userDoc.data();

//       if (userData == null) return;

//       // Create announcement document
//       await _firestore
//           .collection('Users')
//           .doc(user.uid)
//           .collection('Announcement')
//           .add({
//         'heading': _headingController.text,
//         'summary': _summaryController.text,
//         'imageLink': _imageLinkController.text,
//         'description': _descriptionController.text,
//         'helplineNumber': _helplineController.text,
//         'link': _linkController.text,
//         'lastDate': _selectedDate?.toIso8601String(),
//         'createdAt': FieldValue.serverTimestamp(),
//         'lastEdited': FieldValue.serverTimestamp(),
//         'state': userData['state'],
//         'district': userData['district'],
//         'block': userData['block'],
//         'office': userData['office'],
//       });

//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Announcement created successfully')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Announcement Form'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _headingController,
//                 decoration: const InputDecoration(
//                   labelText: 'Heading',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Heading is required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _summaryController,
//                 decoration: const InputDecoration(
//                   labelText: 'Summary',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 2,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Summary is required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _imageLinkController,
//                 decoration: const InputDecoration(
//                   labelText: 'Image Link',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 4,
//                 validator: (value) =>
//                     value?.isEmpty ?? true ? 'Description is required' : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _helplineController,
//                 decoration: const InputDecoration(
//                   labelText: 'Helpline Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.phone,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _linkController,
//                 decoration: const InputDecoration(
//                   labelText: 'Link',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _lastDateController,
//                 decoration: const InputDecoration(
//                   labelText: 'Last Date (Optional)',
//                   border: OutlineInputBorder(),
//                   suffixIcon: Icon(Icons.calendar_today),
//                 ),
//                 readOnly: true,
//                 onTap: () => _selectDate(context),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submitAnnouncement,
//                   child: const Text('Submit'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
