import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'LoginPage.dart';
import 'AnnouncementDetailPage.dart';
import 'theme.dart'; // Import the new theme file

class EmployHome extends StatefulWidget {
  const EmployHome({super.key});

  @override
  State<EmployHome> createState() => _EmployHomeState();
}

class _EmployHomeState extends State<EmployHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('Users').doc(user.uid).get();
      setState(() {
        userData = doc.data();
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showAnnouncementForm() {
    // Check if user is active and verified
    final bool isActive = userData?['isActive'] ?? false;
    final bool isVerified = userData?['isVerified'] ?? false;

    if (!isActive) {
      _showErrorDialog('Account Disabled',
          'Your account is currently disabled. Please contact the admin for activation.');
      return;
    }

    if (!isVerified) {
      _showErrorDialog('Account Not Verified',
          'Your account verification is not complete. Please wait for admin verification.');
      return;
    }

    // If user is both active and verified, show the form
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AnnouncementFormSheet(),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDrawer() {
    String? profileImageUrl = userData?['profilePicLink'];
    String name = userData?['name'] ?? 'Employee';
    String email = userData?['email'] ?? '';

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Custom drawer header with larger avatar
            Container(
              padding: EdgeInsets.only(
                top: 24 + MediaQuery.of(context).padding.top,
                bottom: 24,
              ),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52, // Much larger avatar
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 80)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Preferences section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Preferences',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              secondary: Icon(
                AppTheme.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              value: AppTheme.isDarkMode,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (bool value) {
                setState(() {
                  AppTheme.isDarkMode = value;
                });
              },
            ),
            const Divider(),
            // Support section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Support',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help_outline,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Help',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                // Navigate to help page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.email,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Contact Us',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                launchUrl(Uri.parse(
                    "mailto:farmflow2025@gmail.com?subject=Enquiring about FarmFlow"));
              },
            ),
            const Divider(),
            // Logout option
            ListTile(
              leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.onSurface),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: _signOut,
            ),
            const SizedBox(height: 50),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© ${DateTime.now().year} Government Portal',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.getCurrentTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Employee Dashboard'),
        ),
        drawer: _buildDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAnnouncementForm,
          child: const Icon(Icons.add),
        ),
        body: userData == null
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ))
            : SafeArea(
                child: _buildDashboard(),
              ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeCard(),
            const SizedBox(height: 16),
            _buildOfficeDetailsCard(),
            const SizedBox(height: 16),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: _buildAnnouncementsSection(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              backgroundImage: userData?['profilePicLink'] != null &&
                      userData?['profilePicLink'].isNotEmpty
                  ? NetworkImage(userData!['profilePicLink'])
                  : null,
              child: userData?['profilePicLink'] == null ||
                      userData?['profilePicLink'].isEmpty
                  ? Icon(Icons.person,
                      color: Theme.of(context).colorScheme.primary, size: 40)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${userData!['name']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Employee ID: ${userData!['employeeId']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Phone: ${userData!['phone'] ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: userData!['isVerified']
                          ? AppTheme.getStatusColor('verified').withOpacity(0.1)
                          : AppTheme.getStatusColor('pending').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          userData!['isVerified']
                              ? Icons.verified
                              : Icons.pending,
                          size: 16,
                          color: userData!['isVerified']
                              ? AppTheme.getStatusColor('verified')
                              : AppTheme.getStatusColor('pending'),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          userData!['isVerified']
                              ? 'Verified'
                              : 'Verification Pending',
                          style: TextStyle(
                            color: userData!['isVerified']
                                ? AppTheme.getStatusColor('verified')
                                : AppTheme.getStatusColor('pending'),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Office Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_city, 'Office', userData!['office']),
            const Divider(height: 16),
            _buildInfoRow(Icons.maps_home_work, 'Block', userData!['block']),
            const Divider(height: 16),
            _buildInfoRow(Icons.location_on, 'District', userData!['district']),
            const Divider(height: 16),
            _buildInfoRow(Icons.public, 'State', userData!['state']),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildAnnouncementsList(),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users')
            .doc(_auth.currentUser?.uid)
            .collection('Announcement')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading announcements',
                style: TextStyle(color: Colors.red[300]),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary));
          }

          final announcements = snapshot.data!.docs;

          if (announcements.isEmpty) {
            return _buildEmptyAnnouncementsView();
          }

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcementDoc = announcements[index];
              final announcement =
                  announcementDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    announcement['heading'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        announcement['summary'] ?? '',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (announcement['lastDate'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: ${DateTime.parse(announcement['lastDate']).toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.campaign,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  isThreeLine: announcement['lastDate'] != null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementDetailPage(
                          announcement: announcement,
                          announcementId: announcementDoc.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyAnnouncementsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.announcement_outlined,
              size: 50,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No announcements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          if (userData!['isActive'] && userData!['isVerified'])
            TextButton.icon(
              icon: Icon(Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary),
              label: Text(
                'Create your first announcement',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: _showAnnouncementForm,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnnouncementFormSheet extends StatefulWidget {
  const AnnouncementFormSheet({super.key});

  @override
  State<AnnouncementFormSheet> createState() => _AnnouncementFormSheetState();
}

class _AnnouncementFormSheetState extends State<AnnouncementFormSheet> {
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
  bool _isLoading = false;

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _lastDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _submitAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      final userData = userDoc.data();

      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Announcement')
          .add({
        'heading': _headingController.text,
        'summary': _summaryController.text,
        'imageLink': _imageLinkController.text,
        'description': _descriptionController.text,
        'helplineNumber': _helplineController.text,
        'link': _linkController.text,
        'lastDate': _selectedDate?.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'state': userData?['state'],
        'district': userData?['district'],
        'block': userData?['block'],
        'office': userData?['office'],
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Announcement created successfully'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Announcement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Theme.of(context).colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildFormField(
                            _headingController,
                            'Heading',
                            'Enter announcement heading',
                            Icons.title,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          _buildFormField(
                            _summaryController,
                            'Summary',
                            'Brief summary',
                            Icons.summarize,
                            maxLines: 2,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          _buildFormField(
                            _imageLinkController,
                            'Image Link',
                            'URL to image (optional)',
                            Icons.image,
                          ),
                          _buildFormField(
                            _descriptionController,
                            'Description',
                            'Detailed description',
                            Icons.description,
                            maxLines: 4,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          _buildFormField(
                            _helplineController,
                            'Helpline',
                            'Contact number (optional)',
                            Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildFormField(
                            _linkController,
                            'Link',
                            'Website URL (optional)',
                            Icons.link,
                          ),
                          TextFormField(
                            controller: _lastDateController,
                            decoration: InputDecoration(
                              labelText: 'Last Date (Optional)',
                              prefixIcon: const Icon(Icons.calendar_today,
                                  color: AppTheme.lightSecondary),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: AppTheme.lightSecondary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppTheme.lightSecondary, width: 2),
                              ),
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0), // Adjust top padding as needed
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.lightSecondary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    _isLoading ? null : _submitAnnouncement,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text('Submit Announcement'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: AppTheme.lightSecondary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.lightSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.lightSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.lightSecondary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: maxLines > 1 ? 16 : 0),
        ),
      ),
    );
  }
}
