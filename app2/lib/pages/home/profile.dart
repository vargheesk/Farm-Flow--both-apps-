import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _profilePicController;

  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedOffice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _profilePicController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('Users').doc(user.uid).get();
      final data = userData.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _profilePicController.text = data['profilePicLink'] ?? '';
          selectedState = data['state'];
          selectedDistrict = data['district'];
          selectedBlock = data['block'];
          selectedOffice = data['office'];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _profilePicController,
                label: 'Profile Picture Link',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Office Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStateField(),
              const SizedBox(height: 16),
              _buildDistrictField(),
              const SizedBox(height: 16),
              _buildBlockField(),
              const SizedBox(height: 16),
              _buildOfficeField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildStateField() {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = selectedState ?? '',
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'State',
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            labelText: 'District',
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            labelText: 'Block',
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            labelText: 'Office',
            border: OutlineInputBorder(),
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
    if (!_formKey.currentState!.validate()) return;

    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null ||
        selectedOffice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all location fields')),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'profilePicLink': _profilePicController.text,
          'state': selectedState,
          'district': selectedDistrict,
          'block': selectedBlock,
          'office': selectedOffice,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
}
