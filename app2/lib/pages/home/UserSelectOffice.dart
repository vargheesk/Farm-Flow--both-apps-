import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../home/home.dart';

class ProfileCompletion extends StatefulWidget {
  const ProfileCompletion({super.key});

  @override
  State<ProfileCompletion> createState() => _ProfileCompletionState();
}

class _ProfileCompletionState extends State<ProfileCompletion> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedOffice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please select your office location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildStateField(),
            const SizedBox(height: 16),
            _buildDistrictField(),
            const SizedBox(height: 16),
            _buildBlockField(),
            const SizedBox(height: 16),
            _buildOfficeField(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateField() {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = selectedState ?? '',
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: selectedState ?? 'State',
            border: const OutlineInputBorder(),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        final states = await _firestore.collection('regions').get();
        return states.docs
            .map((doc) => doc.id)
            .where(
                (state) => state.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, state) => ListTile(title: Text(state)),
      onSelected: (state) => setState(() {
        selectedState = state;
        selectedDistrict = null;
        selectedBlock = null;
        selectedOffice = null;
      }),
    );
  }

  Widget _buildDistrictField() {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = selectedDistrict ?? '',
          focusNode: focusNode,
          enabled: selectedState != null,
          decoration: InputDecoration(
            labelText: selectedDistrict ?? 'District',
            border: const OutlineInputBorder(),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (selectedState == null) return [];
        final districts = await _firestore
            .collection('regions')
            .doc(selectedState)
            .collection('districts')
            .get();
        return districts.docs
            .map((doc) => doc.id)
            .where((district) =>
                district.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, district) => ListTile(title: Text(district)),
      onSelected: (district) => setState(() {
        selectedDistrict = district;
        selectedBlock = null;
        selectedOffice = null;
      }),
    );
  }

  Widget _buildBlockField() {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = selectedBlock ?? '',
          focusNode: focusNode,
          enabled: selectedDistrict != null,
          decoration: InputDecoration(
            labelText: selectedBlock ?? 'Block',
            border: const OutlineInputBorder(),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (selectedState == null || selectedDistrict == null) return [];
        final blocks = await _firestore
            .collection('regions')
            .doc(selectedState)
            .collection('districts')
            .doc(selectedDistrict)
            .collection('blocks')
            .get();
        return blocks.docs
            .map((doc) => doc.id)
            .where(
                (block) => block.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, block) => ListTile(title: Text(block)),
      onSelected: (block) => setState(() {
        selectedBlock = block;
        selectedOffice = null;
      }),
    );
  }

  Widget _buildOfficeField() {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = selectedOffice ?? '',
          focusNode: focusNode,
          enabled: selectedBlock != null,
          decoration: InputDecoration(
            labelText: selectedOffice ?? 'Office',
            border: const OutlineInputBorder(),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        if (selectedState == null ||
            selectedDistrict == null ||
            selectedBlock == null) return [];
        final offices = await _firestore
            .collection('regions')
            .doc(selectedState)
            .collection('districts')
            .doc(selectedDistrict)
            .collection('blocks')
            .doc(selectedBlock)
            .collection('offices')
            .get();
        return offices.docs
            .map((doc) => doc.data()['name'] as String)
            .where((office) =>
                office.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, office) => ListTile(title: Text(office)),
      onSelected: (office) => setState(() => selectedOffice = office),
    );
  }

  Future<void> _saveProfile() async {
    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null ||
        selectedOffice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'state': selectedState,
          'district': selectedDistrict,
          'block': selectedBlock,
          'office': selectedOffice,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
}
