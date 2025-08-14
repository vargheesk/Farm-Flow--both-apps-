import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app2/pages/home/geoapify_location_picker.dart';
import 'package:latlong2/latlong.dart';

class ShopProfile extends StatefulWidget {
  const ShopProfile({Key? key}) : super(key: key);

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'shopName': TextEditingController(),
    'shopAddress': TextEditingController(),
    'licenseNumber': TextEditingController(),
    'aadharNumber': TextEditingController(),
    'shopImageLink': TextEditingController(),
    'whatsappNumber': TextEditingController(),
    'landlineNumber': TextEditingController(),
    'website': TextEditingController(),
  };
  LatLng? _location;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final shopDetails = doc.data()?['shopDetails'] as Map<String, dynamic>;
    final GeoPoint geoPoint = shopDetails['location'];

    setState(() {
      _controllers.forEach((key, controller) {
        controller.text = shopDetails[key]?.toString() ?? '';
      });
      _location = LatLng(geoPoint.latitude, geoPoint.longitude);
    });
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GeoapifyLocationPicker()),
    );
    if (result != null) {
      setState(() => _location = result);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _location == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'shopDetails': {
          ..._controllers
              .map((key, controller) => MapEntry(key, controller.text)),
          'location': GeoPoint(_location!.latitude, _location!.longitude),
        }
      });
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    }
  }

  Widget _buildField(String label, String controller,
      {bool enabled = false, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[controller],
        enabled: enabled,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: required
            ? (value) => value?.isEmpty ?? true ? 'Required field' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
        backgroundColor: const Color.fromARGB(255, 195, 245, 197),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField('Shop Name', 'shopName', enabled: _isEditing),
              _buildField('Shop Address', 'shopAddress', enabled: _isEditing),
              _buildField('License Number', 'licenseNumber',
                  enabled: _isEditing),
              _buildField('Aadhar Number', 'aadharNumber', enabled: _isEditing),
              _buildField('Shop Image Link', 'shopImageLink',
                  enabled: _isEditing),
              _buildField('WhatsApp Number', 'whatsappNumber',
                  enabled: _isEditing),
              _buildField('Landline Number', 'landlineNumber',
                  enabled: _isEditing),
              _buildField('Website', 'website',
                  enabled: _isEditing, required: false),
              if (_location != null) ...[
                const SizedBox(height: 16),
                Text(
                    'Location: ${_location!.latitude}, ${_location!.longitude}'),
              ],
              if (_isEditing) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Update Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
