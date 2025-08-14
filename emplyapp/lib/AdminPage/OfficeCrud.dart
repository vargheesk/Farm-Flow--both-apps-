// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MaterialApp(
//     theme: ThemeData(
//       primarySwatch: Colors.blue,
//       inputDecorationTheme: const InputDecorationTheme(
//         border: OutlineInputBorder(),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       ),
//     ),
//     home: const DataEntryForm(),
//   ));
// }

// class DataEntryForm extends StatefulWidget {
//   const DataEntryForm({super.key});

//   @override
//   State<DataEntryForm> createState() => _DataEntryFormState();
// }

// class _DataEntryFormState extends State<DataEntryForm> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? selectedState;
//   String? selectedDistrict;
//   String? selectedBlock;

//   Widget _buildStateField() {
//     return Column(
//       children: [
//         TypeAheadField<String>(
//           builder: (context, controller, focusNode) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'State',
//                 hintText: 'Select existing or enter new state',
//               ),
//             );
//           },
//           suggestionsCallback: (pattern) async {
//             try {
//               final states = await _firestore.collection('regions').get();
//               return states.docs
//                   .map((doc) => doc.id)
//                   .where((state) =>
//                       state.toLowerCase().contains(pattern.toLowerCase()))
//                   .toList();
//             } catch (e) {
//               debugPrint('Error fetching states: $e');
//               return [];
//             }
//           },
//           itemBuilder: (context, state) => ListTile(title: Text(state)),
//           onSelected: (state) => setState(() {
//             selectedState = state;
//             selectedDistrict = null;
//             selectedBlock = null;
//           }),
//         ),
//         const SizedBox(height: 8),
//         ValueListenableBuilder<TextEditingValue>(
//           valueListenable: TextEditingController(),
//           builder: (context, value, child) {
//             return Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New State'),
//                     onPressed: () => _showAddDialog(
//                       title: 'Add New State',
//                       onAdd: (name) => _addState(name),
//                     ),
//                   ),
//                 ),
//                 if (selectedState != null) ...[
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.edit),
//                       label: const Text('Update State'),
//                       onPressed: () => _showUpdateDialog(
//                         title: 'Update State',
//                         currentValue: selectedState!,
//                         onUpdate: (newName) =>
//                             _updateState(selectedState!, newName),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildDistrictField() {
//     return Column(
//       children: [
//         TypeAheadField<String>(
//           builder: (context, controller, focusNode) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               enabled: selectedState != null,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'District',
//                 hintText: 'Select existing or enter new district',
//               ),
//             );
//           },
//           suggestionsCallback: (pattern) async {
//             if (selectedState == null) return [];
//             try {
//               final districts = await _firestore
//                   .collection('regions')
//                   .doc(selectedState)
//                   .collection('districts')
//                   .get();
//               return districts.docs
//                   .map((doc) => doc.id)
//                   .where((district) =>
//                       district.toLowerCase().contains(pattern.toLowerCase()))
//                   .toList();
//             } catch (e) {
//               debugPrint('Error fetching districts: $e');
//               return [];
//             }
//           },
//           itemBuilder: (context, district) => ListTile(title: Text(district)),
//           onSelected: (district) => setState(() {
//             selectedDistrict = district;
//             selectedBlock = null;
//           }),
//         ),
//         const SizedBox(height: 8),
//         if (selectedState != null)
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add New District'),
//                   onPressed: () => _showAddDialog(
//                     title: 'Add New District',
//                     onAdd: (name) => _addDistrict(name),
//                   ),
//                 ),
//               ),
//               if (selectedDistrict != null) ...[
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.edit),
//                     label: const Text('Update District'),
//                     onPressed: () => _showUpdateDialog(
//                       title: 'Update District',
//                       currentValue: selectedDistrict!,
//                       onUpdate: (newName) =>
//                           _updateDistrict(selectedDistrict!, newName),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildBlockField() {
//     return Column(
//       children: [
//         TypeAheadField<String>(
//           builder: (context, controller, focusNode) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               enabled: selectedDistrict != null,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Block',
//                 hintText: 'Select existing or enter new block',
//               ),
//             );
//           },
//           suggestionsCallback: (pattern) async {
//             if (selectedState == null || selectedDistrict == null) return [];
//             try {
//               final blocks = await _firestore
//                   .collection('regions')
//                   .doc(selectedState)
//                   .collection('districts')
//                   .doc(selectedDistrict)
//                   .collection('blocks')
//                   .get();
//               return blocks.docs
//                   .map((doc) => doc.id)
//                   .where((block) =>
//                       block.toLowerCase().contains(pattern.toLowerCase()))
//                   .toList();
//             } catch (e) {
//               debugPrint('Error fetching blocks: $e');
//               return [];
//             }
//           },
//           itemBuilder: (context, block) => ListTile(title: Text(block)),
//           onSelected: (block) => setState(() {
//             selectedBlock = block;
//           }),
//         ),
//         const SizedBox(height: 8),
//         if (selectedDistrict != null)
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   icon: const Icon(Icons.add),
//                   label: const Text('Add New Block'),
//                   onPressed: () => _showAddDialog(
//                     title: 'Add New Block',
//                     onAdd: (name) => _addBlock(name),
//                   ),
//                 ),
//               ),
//               if (selectedBlock != null) ...[
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.edit),
//                     label: const Text('Update Block'),
//                     onPressed: () => _showUpdateDialog(
//                       title: 'Update Block',
//                       currentValue: selectedBlock!,
//                       onUpdate: (newName) =>
//                           _updateBlock(selectedBlock!, newName),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//       ],
//     );
//   }

//   Widget _buildOfficeField() {
//     return Column(
//       children: [
//         TypeAheadField<String>(
//           builder: (context, controller, focusNode) {
//             return TextField(
//               controller: controller,
//               focusNode: focusNode,
//               enabled: selectedBlock != null,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Office',
//                 hintText: 'Enter new office name',
//               ),
//             );
//           },
//           suggestionsCallback: (pattern) async {
//             if (selectedState == null ||
//                 selectedDistrict == null ||
//                 selectedBlock == null) return [];
//             try {
//               final offices = await _firestore
//                   .collection('regions')
//                   .doc(selectedState)
//                   .collection('districts')
//                   .doc(selectedDistrict)
//                   .collection('blocks')
//                   .doc(selectedBlock)
//                   .collection('offices')
//                   .get();
//               return offices.docs
//                   .map((doc) => doc.data()['name'] as String)
//                   .where((office) =>
//                       office.toLowerCase().contains(pattern.toLowerCase()))
//                   .toList();
//             } catch (e) {
//               debugPrint('Error fetching offices: $e');
//               return [];
//             }
//           },
//           itemBuilder: (context, office) => ListTile(title: Text(office)),
//           onSelected: (_) {},
//         ),
//         const SizedBox(height: 8),
//         if (selectedBlock != null)
//           ElevatedButton.icon(
//             icon: const Icon(Icons.add),
//             label: const Text('Add New Office'),
//             onPressed: () => _showAddDialog(
//               title: 'Add New Office',
//               onAdd: (name) => _addOffice(name),
//             ),
//           ),
//       ],
//     );
//   }

//   Future<void> _showAddDialog({
//     required String title,
//     required Future<void> Function(String) onAdd,
//   }) async {
//     final controller = TextEditingController();
//     final result = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'Name',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, controller.text),
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );

//     if (result != null && result.isNotEmpty) {
//       try {
//         await onAdd(result);
//         _showSnackBar('Added successfully');
//       } catch (e) {
//         _showSnackBar('Error: $e');
//       }
//     }
//   }

//   Future<void> _showUpdateDialog({
//     required String title,
//     required String currentValue,
//     required Future<void> Function(String) onUpdate,
//   }) async {
//     final controller = TextEditingController(text: currentValue);
//     final result = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(
//             labelText: 'New Name',
//             border: OutlineInputBorder(),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, controller.text),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );

//     if (result != null && result.isNotEmpty && result != currentValue) {
//       try {
//         await onUpdate(result);
//         _showSnackBar('Updated successfully');
//       } catch (e) {
//         _showSnackBar('Error: $e');
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   Future<void> _addState(String name) async {
//     await _firestore.collection('regions').doc(name).set({
//       'name': name,
//       'type': 'state',
//       'lastUpdated': FieldValue.serverTimestamp(),
//     });
//     setState(() => selectedState = name);
//   }

//   Future<void> _updateState(String oldName, String newName) async {
//     // Start a batch write
//     final batch = _firestore.batch();

//     // Get all districts under the old state
//     final districts = await _firestore
//         .collection('regions')
//         .doc(oldName)
//         .collection('districts')
//         .get();

//     // Create new state document
//     batch.set(_firestore.collection('regions').doc(newName), {
//       'name': newName,
//       'type': 'state',
//       'lastUpdated': FieldValue.serverTimestamp(),
//     });

//     // Copy all districts to new state
//     for (var district in districts.docs) {
//       batch.set(
//         _firestore
//             .collection('regions')
//             .doc(newName)
//             .collection('districts')
//             .doc(district.id),
//         district.data(),
//       );
//     }

//     // Delete old state document
//     batch.delete(_firestore.collection('regions').doc(oldName));

//     // Commit the batch
//     await batch.commit();

//     setState(() => selectedState = newName);
//   }

//   Future<void> _addDistrict(String name) async {
//     if (selectedState == null) return;

//     await _firestore
//         .collection('regions')
//         .doc(selectedState)
//         .collection('districts')
//         .doc(name)
//         .set({
//       'name': name,
//       'type': 'district',
//       'state': selectedState,
//       'lastUpdated': FieldValue.serverTimestamp(),
//     });
//     setState(() => selectedDistrict = name);
//   }

//   Future<void> _updateDistrict(String oldName, String newName) async {
//     if (selectedState == null) return;

//     final batch = _firestore.batch();

//     // Get all blocks under the old district
//     final blocks = await _firestore
//         .collection('regions')
//         .doc(selectedState)
//         .collection('districts')
//         .doc(oldName)
//         .collection('blocks')
//         .get();

//     // Create new district document
//     batch.set(
//       _firestore
//           .collection('regions')
//           .doc(selectedState)
//           .collection('districts')
//           .doc(newName),
//       {
//         'name': newName,
//         'type': 'district',
//         'state': selectedState,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       },
//     );

//     // Copy all blocks to new district
//     for (var block in blocks.docs) {
//       batch.set(
//         _firestore
//             .collection('regions')
//             .doc(selectedState)
//             .collection('districts')
//             .doc(newName)
//             .collection('blocks')
//             .doc(block.id),
//         block.data(),
//       );
//     }

//     // Delete old district document
//     batch.delete(
//       _firestore
//           .collection('regions')
//           .doc(selectedState)
//           .collection('districts')
//           .doc(oldName),
//     );

//     await batch.commit();
//     setState(() => selectedDistrict = newName);
//   }

//   Future<void> _addBlock(String name) async {
//     if (selectedState == null || selectedDistrict == null) return;

//     await _firestore
//         .collection('regions')
//         .doc(selectedState)
//         .collection('districts')
//         .doc(selectedDistrict)
//         .collection('blocks')
//         .doc(name)
//         .set({
//       'name': name,
//       'type': 'block',
//       'district': selectedDistrict,
//       'state': selectedState,
//       'lastUpdated': FieldValue.serverTimestamp(),
//     });
//     setState(() => selectedBlock = name);
//   }

//   Future<void> _updateBlock(String oldName, String newName) async {
//     if (selectedState == null || selectedDistrict == null) return;

//     final batch = _firestore.batch();

//     // Get all offices under the old block
//     final offices = await _firestore
//         .collection('regions')
//         .doc(selectedState)
//         .collection('districts')
//         .doc(selectedDistrict)
//         .collection('blocks')
//         .doc(oldName)
//         .collection('offices')
//         .get();

//     // Create new block document
//     batch.set(
//       _firestore
//           .collection('regions')
//           .doc(selectedState)
//           .collection('districts')
//           .doc(selectedDistrict)
//           .collection('blocks')
//           .doc(newName),
//       {
//         'name': newName,
//         'type': 'block',
//         'district': selectedDistrict,
//         'state': selectedState,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       },
//     );

//     // Copy all offices to new block
//     for (var office in offices.docs) {
//       batch.set(
//         _firestore
//             .collection('regions')
//             .doc(selectedState)
//             .collection('districts')
//             .doc(selectedDistrict)
//             .collection('blocks')
//             .doc(newName)
//             .collection('offices')
//             .doc(office.id),
//         office.data(),
//       );
//     }

//     // Delete old block document
//     batch.delete(
//       _firestore
//           .collection('regions')
//           .doc(selectedState)
//           .collection('districts')
//           .doc(selectedDistrict)
//           .collection('blocks')
//           .doc(oldName),
//     );

//     await batch.commit();
//     setState(() => selectedBlock = newName);
//   }

//   Future<void> _addOffice(String name) async {
//     if (selectedState == null ||
//         selectedDistrict == null ||
//         selectedBlock == null) return;

//     await _firestore
//         .collection('regions')
//         .doc(selectedState)
//         .collection('districts')
//         .doc(selectedDistrict)
//         .collection('blocks')
//         .doc(selectedBlock)
//         .collection('offices')
//         .add({
//       'name': name,
//       'type': 'office',
//       'block': selectedBlock,
//       'district': selectedDistrict,
//       'state': selectedState,
//       'lastUpdated': FieldValue.serverTimestamp(),
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Data Entry Form')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildStateField(),
//             const SizedBox(height: 24),
//             _buildDistrictField(),
//             const SizedBox(height: 24),
//             _buildBlockField(),
//             const SizedBox(height: 24),
//             _buildOfficeField(),
//           ],
//         ),
//       ),
//     );
//   }
// }
