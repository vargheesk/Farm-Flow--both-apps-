import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'employhome.dart';
import 'AdminPage/adminhome.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Office Management',
      debugShowCheckedModeBanner: false, // Add this line
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String?> checkAuthStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();
      return userDoc.data()?['role'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data == 'admin') {
            return const AdminHome();
          } else if (snapshot.data == 'govt_employee') {
            return const EmployHome();
          }
        }

        return const LoginPage();
      },
    );
  }
}
// Dummy user createtion code
//
//
//
//
//
//

//
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:flutter/foundation.dart';
// import 'package:universal_html/html.dart' as html;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Firebase CSV Upload',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: UserUploadScreen(),
//     );
//   }
// }

// class UserUploadScreen extends StatefulWidget {
//   @override
//   _UserUploadScreenState createState() => _UserUploadScreenState();
// }

// class _UserUploadScreenState extends State<UserUploadScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<List<dynamic>> _csvData = [];
//   bool _isLoading = false;
//   String _statusMessage = '';
//   int _successCount = 0;
//   int _errorCount = 0;

//   Future<void> _pickCSVFile() async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Selecting file...';
//     });

//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['csv'],
//       );

//       if (result != null) {
//         if (kIsWeb) {
//           // Web platform
//           final bytes = result.files.first.bytes!;
//           final csvString = String.fromCharCodes(bytes);
//           _loadCSVData(csvString);
//         } else {
//           // Mobile platform
//           File file = File(result.files.single.path!);
//           final csvString = await file.readAsString();
//           _loadCSVData(csvString);
//         }
//       } else {
//         setState(() {
//           _statusMessage = 'No file selected';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error picking file: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   void _loadCSVData(String csvString) {
//     try {
//       _csvData = const CsvToListConverter().convert(csvString);
//       setState(() {
//         _statusMessage =
//             'File loaded successfully. Found ${_csvData.length - 1} records.';
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error parsing CSV: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _uploadToFirebase() async {
//     if (_csvData.isEmpty) {
//       setState(() {
//         _statusMessage = 'No data to upload';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Uploading data to Firebase...';
//       _successCount = 0;
//       _errorCount = 0;
//     });

//     try {
//       // Get header row
//       List<dynamic> headers = _csvData[0];

//       // Process data rows
//       for (int i = 1; i < _csvData.length; i++) {
//         try {
//           Map<String, dynamic> userData = {};

//           // Convert row to map using headers
//           for (int j = 0; j < headers.length; j++) {
//             if (j < _csvData[i].length) {
//               String key = headers[j].toString();
//               dynamic value = _csvData[i][j];

//               // Convert string "True"/"False" to bool
//               if (key == "isActive") {
//                 value = value.toString().toLowerCase() == "true";
//               }

//               userData[key] = value;
//             }
//           }

//           // Generate a timestamp for createdAt field like in your example
//           userData['createdAt'] = DateTime.now().toString();

//           // Upload to Firestore
//           await _firestore.collection('Users').add(userData);
//           _successCount++;

//           setState(() {
//             _statusMessage =
//                 'Uploading: $_successCount successful, $_errorCount failed';
//           });
//         } catch (e) {
//           _errorCount++;
//           print('Error uploading record $i: $e');
//         }
//       }

//       setState(() {
//         _statusMessage =
//             'Upload complete: $_successCount successful, $_errorCount failed';
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error during upload: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Firebase CSV User Upload'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Upload Users from CSV to Firebase',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 30),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _pickCSVFile,
//                 child: Text('Select CSV File'),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//               ),
//               SizedBox(height: 20),
//               if (_csvData.isNotEmpty)
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _uploadToFirebase,
//                   child: Text('Upload to Firebase'),
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     backgroundColor: Colors.green,
//                   ),
//                 ),
//               SizedBox(height: 20),
//               if (_isLoading) CircularProgressIndicator(),
//               SizedBox(height: 20),
//               Text(
//                 _statusMessage,
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 40),
//               if (_csvData.isNotEmpty)
//                 Expanded(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           columns: _csvData[0]
//                               .map((header) =>
//                                   DataColumn(label: Text(header.toString())))
//                               .toList(),
//                           rows: _csvData
//                               .skip(1)
//                               .map(
//                                 (row) => DataRow(
//                                   cells: row
//                                       .map((cell) =>
//                                           DataCell(Text(cell.toString())))
//                                       .toList(),
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
