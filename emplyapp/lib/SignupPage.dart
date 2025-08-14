import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// Define the theme colors (matching EmployHome)
class AppTheme {
  static const Color primaryColor = Color(0xFFE8EAF6);
  // Color.fromARGB(255, 65, 157, 254); // Navy blue
  static const Color accentColor = Color(0xFF1A73E8); // Bright blue
  static const Color cardColor =
      Color.fromARGB(255, 214, 227, 241); // Slightly lighter navy
  static const Color textColor = Color.fromARGB(255, 14, 14, 15); // Light blue-white
  static const Color secondaryTextColor = Color.fromARGB(255, 79, 82, 84); // Light gray-blue
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? selectedState;
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedOffice;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _profilePicLinkController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeIdController.dispose();
    _phoneController.dispose();
    _aadharController.dispose();
    _profilePicLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.primaryColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppTheme.cardColor,
          labelStyle: const TextStyle(color: AppTheme.secondaryTextColor),
          hintStyle:
              TextStyle(color: AppTheme.secondaryTextColor.withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 159, 201, 255), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: AppTheme.textColor),
          bodyLarge: TextStyle(color: AppTheme.textColor),
          bodyMedium: TextStyle(color: AppTheme.secondaryTextColor),
        ),
        colorScheme: ColorScheme.dark(
          primary: AppTheme.accentColor,
          secondary: const Color.fromARGB(255, 88, 159, 251),
          surface: const Color.fromARGB(255, 52, 99, 152),
          background: const Color.fromARGB(255, 182, 217, 255),
          onPrimary: AppTheme.textColor,
          onSurface: AppTheme.textColor,
          onBackground: AppTheme.textColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account',
              style: TextStyle(color: AppTheme.textColor)),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _employeeIdController,
                        labelText: 'Employee ID',
                        hintText: 'Enter your employee ID',
                        prefixIcon: Icons.badge,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Employee ID is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        labelText: 'Phone Number',
                        hintText: 'Enter your 10-digit phone number',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Phone number is required';
                          if (!RegExp(r'^\d{10}$').hasMatch(value!)) {
                            return 'Enter valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _aadharController,
                        labelText: 'Aadhar Number',
                        hintText: 'Enter your 12-digit Aadhar number',
                        prefixIcon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Aadhar number is required';
                          if (!RegExp(r'^\d{12}$').hasMatch(value!)) {
                            return 'Enter valid 12-digit Aadhar number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _profilePicLinkController,
                        labelText: 'Profile Picture Link (Optional)',
                        hintText: 'Enter URL to your profile picture',
                        prefixIcon: Icons.image,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Office Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeAheadField(
                        labelText: 'State',
                        hintText: 'Select your state',
                        prefixIcon: Icons.public,
                        initialValue: selectedState,
                        enabled: true,
                        suggestionsCallback: (pattern) async {
                          final states =
                              await _firestore.collection('regions').get();
                          return states.docs
                              .map((doc) => doc.id)
                              .where((state) => state
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        onSelected: (state) => setState(() {
                          selectedState = state;
                          selectedDistrict = null;
                          selectedBlock = null;
                          selectedOffice = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeAheadField(
                        labelText: 'District',
                        hintText: 'Select your district',
                        prefixIcon: Icons.location_city,
                        initialValue: selectedDistrict,
                        enabled: selectedState != null,
                        suggestionsCallback: (pattern) async {
                          if (selectedState == null) return [];
                          final districts = await _firestore
                              .collection('regions')
                              .doc(selectedState)
                              .collection('districts')
                              .get();
                          return districts.docs
                              .map((doc) => doc.id)
                              .where((district) => district
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        onSelected: (district) => setState(() {
                          selectedDistrict = district;
                          selectedBlock = null;
                          selectedOffice = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeAheadField(
                        labelText: 'Block',
                        hintText: 'Select your block',
                        prefixIcon: Icons.domain,
                        initialValue: selectedBlock,
                        enabled: selectedDistrict != null,
                        suggestionsCallback: (pattern) async {
                          if (selectedState == null || selectedDistrict == null)
                            return [];
                          final blocks = await _firestore
                              .collection('regions')
                              .doc(selectedState)
                              .collection('districts')
                              .doc(selectedDistrict)
                              .collection('blocks')
                              .get();
                          return blocks.docs
                              .map((doc) => doc.id)
                              .where((block) => block
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        onSelected: (block) => setState(() {
                          selectedBlock = block;
                          selectedOffice = null;
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildTypeAheadField(
                        labelText: 'Office',
                        hintText: 'Select your office',
                        prefixIcon: Icons.business,
                        initialValue: selectedOffice,
                        enabled: selectedBlock != null,
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
                              .where((office) => office
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .toList();
                        },
                        onSelected: (office) =>
                            setState(() => selectedOffice = office),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Email is required';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Enter valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Create a password (6+ characters)',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Password is required';
                          if (value!.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Confirm password is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: AppTheme.textColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _signUp,
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style:
                                TextStyle(color: AppTheme.secondaryTextColor),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: AppTheme.accentColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: AppTheme.accentColor),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }

  Widget _buildTypeAheadField({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? initialValue,
    required bool enabled,
    required Future<List<String>> Function(String) suggestionsCallback,
    required void Function(String) onSelected,
  }) {
    return TypeAheadField<String>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller..text = initialValue ?? '',
          focusNode: focusNode,
          enabled: enabled,
          style: const TextStyle(color: AppTheme.textColor),
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: Icon(prefixIcon, color: AppTheme.accentColor),
            suffixIcon: enabled
                ? const Icon(Icons.arrow_drop_down, color: AppTheme.accentColor)
                : null,
          ),
        );
      },
      suggestionsCallback: suggestionsCallback,
      itemBuilder: (context, suggestion) => ListTile(
        title:
            Text(suggestion, style: const TextStyle(color: AppTheme.textColor)),
        tileColor: AppTheme.cardColor,
      ),
      onSelected: onSelected,
      hideOnError: true,
      hideOnEmpty: true,
      hideOnLoading: true,
      decorationBuilder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedState == null ||
        selectedDistrict == null ||
        selectedBlock == null ||
        selectedOffice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all location fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'state': selectedState,
        'district': selectedDistrict,
        'block': selectedBlock,
        'office': selectedOffice,
        'employeeId': _employeeIdController.text,
        'phone': _phoneController.text,
        'aadhar': _aadharController.text,
        'profilePicLink': _profilePicLinkController.text,
        'role': 'govt_employee',
        'isActive': true, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Account created successfully! Waiting for verification.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().split('] ').last}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
