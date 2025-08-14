
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AnnouncementDetail extends StatelessWidget {
//   final Map<String, dynamic> announcement;

//   const AnnouncementDetail({super.key, required this.announcement});

//   String _getGoogleDriveImageUrl(String? driveUrl) {
//     if (driveUrl == null || driveUrl.isEmpty) {
//       return ''; // Return empty string to trigger placeholder container
//     }

//     if (driveUrl.contains('drive.google.com')) {
//       String? fileId;

//       if (driveUrl.contains('/file/d/')) {
//         fileId = driveUrl.split('/file/d/')[1].split('/')[0];
//       } else if (driveUrl.contains('id=')) {
//         fileId = driveUrl.split('id=')[1].split('&')[0];
//       }

//       if (fileId != null && fileId.isNotEmpty) {
//         return 'https://drive.google.com/uc?export=view&id=$fileId';
//       }
//     }

//     return '';
//   }

// // In your Image.network widget, replace with:
//   Widget _buildImage(String imageUrl) {
//     return imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             width: 96,
//             height: 96,
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return _buildPlaceholder(true);
//             },
//             errorBuilder: (context, error, stackTrace) {
//               debugPrint('Image Error: $error');
//               return _buildPlaceholder(false);
//             },
//           )
//         : _buildPlaceholder(false);
//   }

// // Add this helper method
//   Widget _buildPlaceholder(bool isLoading) {
//     return Container(
//       width: 96,
//       height: 96,
//       color: Colors.grey[200],
//       child: Center(
//         child: isLoading
//             ? const CircularProgressIndicator()
//             : const Icon(Icons.image_not_supported),
//       ),
//     );
//   }

//   Future<void> _launchURL(String url) async {
//     if (url.isEmpty) return;
//     final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (e) {
//       debugPrint('Could not launch $url: $e');
//     }
//   }

//   Future<void> _launchPhone(String phoneNumber) async {
//     if (phoneNumber.isEmpty) return;
//     final Uri uri = Uri.parse('tel:$phoneNumber');
//     try {
//       await launchUrl(uri);
//     } catch (e) {
//       debugPrint('Could not launch $phoneNumber: $e');
//     }
//   }

//   String _formatDate(dynamic dateData) {
//     try {
//       DateTime date;
//       if (dateData is Timestamp) {
//         date = dateData.toDate();
//       } else if (dateData is String) {
//         date = DateTime.parse(dateData);
//       } else {
//         return '';
//       }
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return '';
//     }
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value,
//       {bool isLink = false}) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.grey[600]),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               color: isLink ? Colors.blue : Colors.grey[600],
//               decoration: isLink ? TextDecoration.underline : null,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = _getGoogleDriveImageUrl(announcement['imageLink']);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Announcement Details'),
//         backgroundColor: const Color(0xFFC3F5C5),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           color: const Color(0xFFC3F5C5),
//           constraints: BoxConstraints(
//             minHeight: MediaQuery.of(context).size.height,
//           ),
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 600),
//                 child: Card(
//                   elevation: 4,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             'Created on ${_formatDate(announcement['createdAt'])}',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: imageUrl.isNotEmpty
//                                       ? Image.network(
//                                           imageUrl,
//                                           width: 96,
//                                           height: 96,
//                                           fit: BoxFit.cover,
//                                           loadingBuilder: (context, child,
//                                               loadingProgress) {
//                                             if (loadingProgress == null)
//                                               return child;
//                                             return Container(
//                                               width: 96,
//                                               height: 96,
//                                               color: Colors.grey[200],
//                                               child: const Center(
//                                                 child:
//                                                     CircularProgressIndicator(),
//                                               ),
//                                             );
//                                           },
//                                           errorBuilder:
//                                               (context, error, stackTrace) {
//                                             debugPrint('Image Error: $error');
//                                             return Container(
//                                               width: 96,
//                                               height: 96,
//                                               color: Colors.grey[200],
//                                               child: const Icon(
//                                                   Icons.image_not_supported),
//                                             );
//                                           },
//                                         )
//                                       : Container(
//                                           width: 96,
//                                           height: 96,
//                                           color: Colors.grey[200],
//                                           child: const Icon(
//                                               Icons.image_not_supported),
//                                         ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Text(
//                                     announcement['heading'] ?? '',
//                                     style: const TextStyle(
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               announcement['summary'] ?? '',
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             const SizedBox(height: 24),
//                             const Text(
//                               'Description :',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               announcement['description'] ?? '',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             InkWell(
//                               onTap: () => _launchPhone(
//                                   announcement['helplineNumber'] ?? ''),
//                               child: _buildInfoRow(
//                                 Icons.phone,
//                                 'Helpline Number :',
//                                 announcement['helplineNumber'] ?? '',
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             InkWell(
//                               onTap: () =>
//                                   _launchURL(announcement['link'] ?? ''),
//                               child: _buildInfoRow(
//                                 Icons.link,
//                                 'Link :',
//                                 announcement['link'] ?? '',
//                                 isLink: true,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             _buildInfoRow(
//                               Icons.calendar_today,
//                               'Last Date :',
//                               _formatDate(announcement['lastDate'] ?? ''),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
