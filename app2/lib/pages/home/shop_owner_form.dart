import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app2/pages/home/geoapify_location_picker.dart';

class ShopOwnerForm extends StatefulWidget {
  const ShopOwnerForm({Key? key}) : super(key: key);

  @override
  State<ShopOwnerForm> createState() => _ShopOwnerFormState();
}

class _ShopOwnerFormState extends State<ShopOwnerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _shopImageController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  InputDecoration _buildInputDecoration(String label, {bool required = true}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.green, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.green.shade700, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  String? _validatePhone(String? value) {
    if (value?.isEmpty ?? true) return 'Required field';
    if (!RegExp(r'^\d{10}$').hasMatch(value!)) return 'Must be 10 digits';
    return null;
  }

  String? _validateLandline(String? value) {
    if (value?.isEmpty ?? true) return 'Required field';
    if (!RegExp(r'^\d{8,12}$').hasMatch(value!)) return 'Must be 8-12 digits';
    return null;
  }

  String? _validateWebsite(String? value) {
    if (value?.isEmpty ?? true) return null;
    if (!Uri.parse(value!).isAbsolute) return 'Enter valid URL';
    return null;
  }

  String? _validateCoordinate(String? value, String type) {
    if (value?.isEmpty ?? true) return 'Required field';
    double? coord = double.tryParse(value!);
    if (coord == null) return 'Enter valid number';
    if (type == 'lat' && (coord < -90 || coord > 90)) {
      return 'Latitude must be between -90 and 90';
    }
    if (type == 'lng' && (coord < -180 || coord > 180)) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  /// Opens a new page with a map (using Geoapify tiles) so the user can select a location.
  void _openLocationPicker() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GeoapifyLocationPicker()),
    );

    if (pickedLocation != null) {
      setState(() {
        _latController.text = pickedLocation.latitude.toString();
        _lngController.text = pickedLocation.longitude.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owner Details'),
        backgroundColor: const Color.fromARGB(255, 195, 245, 197),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _shopNameController,
                          decoration: _buildInputDecoration('Shop Name'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required field' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _shopAddressController,
                          decoration: _buildInputDecoration('Shop Address'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required field' : null,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _licenseController,
                          decoration: _buildInputDecoration('License Number'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required field' : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _aadharController,
                          decoration:
                              _buildInputDecoration('Aadhar Card Number'),
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required field';
                            if (value!.length != 12) return 'Must be 12 digits';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _whatsappController,
                          decoration: _buildInputDecoration('WhatsApp Number'),
                          keyboardType: TextInputType.phone,
                          validator: _validatePhone,
                          maxLength: 10,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _landlineController,
                          decoration: _buildInputDecoration('Landline Number'),
                          keyboardType: TextInputType.phone,
                          validator: _validateLandline,
                          maxLength: 12,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _websiteController,
                          decoration:
                              _buildInputDecoration('Website', required: false),
                          keyboardType: TextInputType.url,
                          validator: _validateWebsite,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _shopImageController,
                          decoration: _buildInputDecoration('Shop Image Link'),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required field' : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _openLocationPicker,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.map, color: Colors.white),
                          label: const Text(
                            'Set Shop Location on Map',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if (_latController.text.isNotEmpty &&
                            _lngController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Location: ${_latController.text}, ${_lngController.text}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  _latController.text.isNotEmpty &&
                                  _lngController.text.isNotEmpty) {
                                try {
                                  String userId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(userId)
                                      .update({
                                    'role': 'shop-owner',
                                    'shopDetails': {
                                      'shopName': _shopNameController.text,
                                      'shopAddress':
                                          _shopAddressController.text,
                                      'licenseNumber': _licenseController.text,
                                      'aadharNumber': _aadharController.text,
                                      'shopImageLink':
                                          _shopImageController.text,
                                      'whatsappNumber':
                                          _whatsappController.text,
                                      'landlineNumber':
                                          _landlineController.text,
                                      'website': _websiteController.text,
                                      'isShopActive': true,
                                      'location': GeoPoint(
                                        double.parse(_latController.text),
                                        double.parse(_lngController.text),
                                      ),
                                    }
                                  });
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Error updating profile')),
                                  );
                                }
                              } else if (_latController.text.isEmpty ||
                                  _lngController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please set shop location')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
