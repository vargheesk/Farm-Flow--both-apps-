import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Add this package to your pubspec.yaml

class TotalUsersListPage extends StatefulWidget {
  const TotalUsersListPage({super.key});

  @override
  State<TotalUsersListPage> createState() => _TotalUsersListPageState();
}

class _TotalUsersListPageState extends State<TotalUsersListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showFilters = false; // Control filter visibility

  // Filter variables
  String? _roleFilter;
  String? _locationFilter;
  bool? _activeFilter;
  List<String> _locations = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('Users').get();

      // Convert QueryDocumentSnapshot to Map and include the document ID
      _allUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      // Extract unique locations for filter
      final Set<String> locationSet = {};
      for (var user in _allUsers) {
        if (user['district'] != null &&
            user['district'].toString().isNotEmpty) {
          locationSet.add(user['district'].toString());
        }
      }
      _locations = locationSet.toList()..sort();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading users: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    return _allUsers.where((user) {
      // Filter out admin users
      if (user['role'] == 'admin') return false;

      // Search filter
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          (user['name']?.toString() ?? '').toLowerCase().contains(query) ||
              (user['email']?.toString() ?? '').toLowerCase().contains(query) ||
              (user['role']?.toString() ?? '').toLowerCase().contains(query);

      // Role filter
      final matchesRole = _roleFilter == null || user['role'] == _roleFilter;

      // Location filter
      final matchesLocation =
          _locationFilter == null || user['district'] == _locationFilter;

      // Active filter
      final matchesActive =
          _activeFilter == null || user['isActive'] == _activeFilter;

      return matchesSearch && matchesRole && matchesLocation && matchesActive;
    }).toList();
  }

  Future<void> _toggleUserActive(Map<String, dynamic> user) async {
    try {
      final bool newActiveState = !(user['isActive'] == true);
      await _firestore
          .collection('Users')
          .doc(user['id'])
          .update({'isActive': newActiveState});

      // Update local state
      setState(() {
        final index = _allUsers.indexWhere((u) => u['id'] == user['id']);
        if (index >= 0) {
          _allUsers[index]['isActive'] = newActiveState;
        }
      });

      // Show toast notification instead of SnackBar
      Fluttertoast.showToast(
          msg:
              'User ${newActiveState ? 'activated' : 'deactivated'} successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Colors.white,
          fontSize: 14.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Failed to update user: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }
  }

  // Add this method to your _TotalUsersListPageState class
  void _showFilterDialog() {
    // Local variables to hold temporary filter values
    String? tempRoleFilter = _roleFilter;
    String? tempLocationFilter = _locationFilter;
    bool? tempActiveFilter = _activeFilter;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.indigo),
                  SizedBox(width: 10),
                  Text('Filter Users', style: TextStyle(fontSize: 18)),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterRow(
                      label: 'Role',
                      selectedValue: tempRoleFilter,
                      options: {
                        'govt_employee': 'Government Employee',
                        'shop-owner': 'Shop Owner',
                        'naive-user': 'General User',
                      },
                      onSelected: (value) {
                        setStateDialog(() {
                          tempRoleFilter = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFilterRow(
                      label: 'Location',
                      selectedValue: tempLocationFilter,
                      options: {for (var loc in _locations) loc: loc},
                      onSelected: (value) {
                        setStateDialog(() {
                          tempLocationFilter = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildFilterRow(
                      label: 'Status',
                      selectedValue: tempActiveFilter?.toString(),
                      options: const {'true': 'Active', 'false': 'Inactive'},
                      onSelected: (value) {
                        setStateDialog(() {
                          tempActiveFilter =
                              value == null ? null : value == 'true';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    setStateDialog(() {
                      tempRoleFilter = null;
                      tempLocationFilter = null;
                      tempActiveFilter = null;
                    });
                  },
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: Text('APPLY', style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    // Update the parent state with the temporary values
                    setState(() {
                      _roleFilter = tempRoleFilter;
                      _locationFilter = tempLocationFilter;
                      _activeFilter = tempActiveFilter;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterRow({
    required String label,
    required String? selectedValue,
    required Map<String, String> options,
    required Function(String?) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('All'),
              value: selectedValue,
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All'),
                ),
                ...options.entries.map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    )),
              ],
              onChanged: (value) => onSelected(value),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllUsers,
            color: Colors.white,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : Column(
              children: [
                // Search bar with filter icon
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Search Users',
                            labelStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.indigo, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showFilterDialog,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _hasActiveFilters()
                                ? Colors.indigo
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: _hasActiveFilters()
                                ? Colors.white
                                : Colors.indigo,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add this Expanded widget with ListView to show users
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_off,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          color: Colors.white, // Set background to white
                          child: ListView.builder(
                            // Changed from ListView.separated (removed separators)
                            padding: const EdgeInsets.all(8),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return _buildUserListItem(filteredUsers[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  bool _hasActiveFilters() {
    return _roleFilter != null ||
        _locationFilter != null ||
        _activeFilter != null;
  }

  Widget _buildFilterChip({
    required String label,
    required String? selectedValue,
    required Map<String, String> options,
    required Function(String?) onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(label, style: TextStyle(fontSize: 12)),
          value: selectedValue,
          icon:
              const Icon(Icons.arrow_drop_down, color: Colors.indigo, size: 18),
          itemHeight: 48,
          style: TextStyle(fontSize: 12, color: Colors.black87),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All', style: TextStyle(fontSize: 12)),
            ),
            ...options.entries
                .map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value, style: TextStyle(fontSize: 12)),
                    ))
                .toList(),
          ],
          onChanged: (value) => onSelected(value),
        ),
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    final isActive = user['isActive'] == true;
    final String role = _formatRole(user['role']?.toString());
    final String status = _getUserStatus(user);

    // Choose status icon and color
    IconData statusIcon;
    Color statusColor;

    if (user['role'] == 'govt_employee') {
      if (user['isVerified'] == true) {
        statusIcon = Icons.verified;
        statusColor = Colors.green;
      } else if (user['verificationRejected'] == true) {
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
      } else {
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
      }
    } else {
      statusIcon = isActive ? Icons.check_circle : Icons.cancel;
      statusColor = isActive ? Colors.green : Colors.red;
    }

    // Apply opacity based on active status - fade inactive users
    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Card(
        elevation: 0.5,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigo.shade100,
            backgroundImage:
                user['profilePicLink']?.toString().isNotEmpty == true
                    ? NetworkImage(user['profilePicLink'])
                    : null,
            child: user['profilePicLink']?.toString().isEmpty == true ||
                    user['profilePicLink'] == null
                ? Icon(Icons.person, color: Colors.indigo.shade700)
                : null,
          ),
          title: Text(
            user['name']?.toString() ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user['email']?.toString() ?? 'N/A',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                          fontSize: 10, color: Colors.indigo.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    status,
                    style: TextStyle(fontSize: 10, color: statusColor),
                  ),
                ],
              ),
            ],
          ),
          trailing: GestureDetector(
            onTap: () => _toggleUserActive(user),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                color: isActive ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
          ),
          onTap: () => _showUserDetails(user),
        ),
      ),
    );
  }

  String _formatRole(String? role) {
    switch (role) {
      case 'govt_employee':
        return 'Government Employee';
      case 'shop-owner':
        return 'Shop Owner';
      case 'naive-user':
        return 'General User';
      default:
        return role ?? 'Unknown';
    }
  }

  String _getUserStatus(Map<String, dynamic> user) {
    if (user['role'] == 'govt_employee') {
      if (user['isVerified'] == true) return 'Verified';
      if (user['verificationRejected'] == true) return 'Rejected';
      return 'Pending';
    }
    return user['isActive'] == true ? 'Active' : 'Inactive';
  }

  // Implement the missing _buildUserHeader method properly
  //
  // Update the _buildUserHeader method for a more compact close button
  Widget _buildUserHeader(Map<String, dynamic> user) {
    final roleColor = user['role'] == 'govt_employee'
        ? Colors.indigo
        : user['role'] == 'shop-owner'
            ? Colors.amber.shade700
            : Colors.purple;

    final roleIcon = user['role'] == 'govt_employee'
        ? Icons.work
        : user['role'] == 'shop-owner'
            ? Icons.store
            : Icons.person;

    // Determine status badge properties
    IconData badgeIcon;
    Color badgeColor;

    if (user['role'] == 'govt_employee') {
      if (user['isVerified'] == true) {
        badgeIcon = Icons.verified;
        badgeColor = Colors.green;
      } else if (user['verificationRejected'] == true) {
        badgeIcon = Icons.cancel;
        badgeColor = Colors.red;
      } else {
        badgeIcon = Icons.pending;
        badgeColor = Colors.amber;
      }
    } else {
      badgeIcon = user['isActive'] == true ? Icons.check_circle : Icons.cancel;
      badgeColor = user['isActive'] == true ? Colors.green : Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Close button positioned in the top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ),
          ),

          // Main content
          Column(
            children: [
              Row(
                children: [
                  // Profile picture with status badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 95,
                        height: 95,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.indigo, width: 2),
                          color: Colors.grey.shade200,
                          image: user['profilePicLink']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? DecorationImage(
                                  image: NetworkImage(user['profilePicLink']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user['profilePicLink']?.toString().isEmpty ==
                                    true ||
                                user['profilePicLink'] == null
                            ? const Icon(Icons.person,
                                size: 40, color: Colors.grey)
                            : null,
                      ),
                      // Status badge with grey ring
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 1.5),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            badgeIcon,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name']?.toString() ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['email']?.toString() ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: roleColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 16, color: roleColor),
                              const SizedBox(width: 6),
                              Text(
                                _formatRole(user['role']?.toString()),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: roleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusIndicator(user),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Map<String, dynamic> user) {
    // For government employees, we'll show both verification status and active status
    if (user['role'] == 'govt_employee') {
      // First determine verification status
      String verificationStatus;
      Color verificationColor;
      IconData verificationIcon;

      if (user['isVerified'] == true) {
        verificationStatus = 'Verified';
        verificationColor = Colors.green;
        verificationIcon = Icons.check_circle;
      } else if (user['verificationRejected'] == true) {
        verificationStatus = 'Rejected';
        verificationColor = Colors.red;
        verificationIcon = Icons.cancel;
      } else {
        verificationStatus = 'Pending';
        verificationColor = Colors.amber;
        verificationIcon = Icons.pending;
      }

      // Now determine active status
      String activeStatus = user['isActive'] == true ? 'Active' : 'Inactive';
      Color activeColor = user['isActive'] == true ? Colors.green : Colors.red;
      IconData activeIcon =
          user['isActive'] == true ? Icons.check_circle : Icons.block;

      // Return a row with both status indicators
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verification status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: verificationColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: verificationColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(verificationIcon, size: 14, color: verificationColor),
                const SizedBox(width: 6),
                Text(
                  verificationStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: verificationColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), // Space between the indicators

          // Active status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: activeColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(activeIcon, size: 14, color: activeColor),
                const SizedBox(width: 6),
                Text(
                  activeStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // For non-government employees, just show active status as before
      String status = user['isActive'] == true ? 'Active' : 'Inactive';
      Color statusColor = user['isActive'] == true
          ? Colors.green
          : const Color.fromARGB(255, 255, 18, 18);
      IconData statusIcon =
          user['isActive'] == true ? Icons.check_circle : Icons.block;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 14, color: statusColor),
            const SizedBox(width: 6),
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    final isActive = user['isActive'] == true;
    final isVerified = user['isVerified'] == true;
    final isRejected = user['verificationRejected'] == true;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User header with profile picture and basic info
            _buildUserHeader(user),

            // Scrollable content area
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Text(
                      //       'User Details',
                      //       style: Theme.of(context)
                      //           .textTheme
                      //           .titleLarge
                      //           ?.copyWith(
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 6,
                      //           ),
                      //     ),
                      //     IconButton(
                      //       icon: const Icon(Icons.close,
                      //           color: Colors.grey, size: 20),
                      //       onPressed: () => Navigator.of(context).pop(),
                      //     ),
                      //   ],
                      // ),
                      // const Divider(),

                      // User details section
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  'Name', user['name'], Icons.person),
                              _buildDetailRow(
                                  'Email', user['email'], Icons.email),
                              _buildDetailRow(
                                  'Phone', user['phone'], Icons.phone),
                              _buildDetailRow(
                                  'Aadhar',
                                  user['aadhar']?.toString() ?? 'N/A',
                                  Icons.credit_card),
                              _buildDetailRow(
                                  'Role',
                                  _formatRole(user['role']?.toString()),
                                  Icons.work),
                              _buildDetailRow('Status', _getUserStatus(user),
                                  _getUserStatusIcon(user)),
                            ],
                          ),
                        ),
                      ),

                      // Conditional sections based on user role
                      if (user['role'] == 'govt_employee')
                        _buildEmployeeDetails(user),
                      if (user['role'] == 'shop-owner') _buildShopDetails(user),
                      if (user['role'] == 'naive-user')
                        _buildNaiveUserDetails(user),

                      // Toggle button
                      // Replace toggle button with icon
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _toggleUserActive(user);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.red.withOpacity(0.3)
                                        : Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.cancel
                                          : Icons.check_circle,
                                      color:
                                          isActive ? Colors.red : Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isActive ? 'Disable User' : 'Enable User',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.red
                                            : Colors.green,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated method for status icon to be more consistent with Figma design
  IconData _getUserStatusIcon(Map<String, dynamic> user) {
    if (user['role'] == 'govt_employee') {
      if (user['isVerified'] == true) return Icons.verified;
      if (user['verificationRejected'] == true) return Icons.cancel;
      return Icons.pending;
    }
    return user['isActive'] == true ? Icons.check_circle : Icons.cancel;
  }

  // Updated method for status color to be more consistent with Figma design
  Color _getUserStatusColor(Map<String, dynamic> user) {
    if (user['role'] == 'govt_employee') {
      if (user['isVerified'] == true) return Colors.green;
      if (user['verificationRejected'] == true) return Colors.red;
      return Colors.orange;
    }
    return user['isActive'] == true ? Colors.green : Colors.red;
  }

  Widget _buildDetailRow(String label, dynamic value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value?.toString() ?? 'N/A',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get the appropriate icon for user role
  IconData _getRoleIcon(String? role) {
    switch (role) {
      case 'govt_employee':
        return Icons.business;
      case 'shop-owner':
        return Icons.store;
      case 'naive-user':
        return Icons.person;
      default:
        return Icons.person;
    }
  }

  Widget _buildUserDetailSection(Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 40, // Slightly reduced
                backgroundColor: Colors.indigo.shade50,
                backgroundImage:
                    user['profilePicLink']?.toString().isNotEmpty == true
                        ? NetworkImage(user['profilePicLink'])
                        : null,
                child: user['profilePicLink']?.toString().isEmpty == true ||
                        user['profilePicLink'] == null
                    ? Icon(Icons.person,
                        size: 40, color: Colors.indigo.shade200)
                    : null,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _getUserStatusColor(user),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  _getUserStatusIcon(user),
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', user['name'], Icons.person),
                _buildDetailRow('Email', user['email'], Icons.email),
                _buildDetailRow('Phone', user['phone'], Icons.phone),
                _buildDetailRow('Aadhar', user['aadhar']?.toString() ?? 'N/A',
                    Icons.credit_card),
                _buildDetailRow(
                    'Role', _formatRole(user['role']?.toString()), Icons.work),
                _buildDetailRow(
                    'Status', _getUserStatus(user), _getUserStatusIcon(user)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDetails(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 0,
        color: Colors.indigo.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.indigo.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: Colors.indigo.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Employee Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Employee ID', user['employeeId'], Icons.badge),
              _buildDetailRow('Office', user['office'], Icons.location_city),
              _buildDetailRow('Block', user['block'], Icons.map),
              _buildDetailRow('District', user['district'], Icons.location_on),
              _buildDetailRow('State', user['state'], Icons.public),
              if (user['isVerified'] != true &&
                  user['verificationRejected'] == true)
                _buildDetailRow(
                    'Rejection Reason', user['rejectionReason'], Icons.warning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopDetails(Map<String, dynamic> user) {
    final shop = user['shopDetails'] ?? {};
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 0,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Shop Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (shop['shopImageLink']?.toString().isNotEmpty == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    shop['shopImageLink'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 12),
              _buildDetailRow('Shop Name', shop['shopName'], Icons.storefront),
              _buildDetailRow(
                  'Address', shop['shopAddress'], Icons.location_on),
              _buildDetailRow(
                  'License', shop['licenseNumber'], Icons.assignment),
              _buildDetailRow('WhatsApp', shop['whatsappNumber'], Icons.chat),
              _buildDetailRow('Landline', shop['landlineNumber'], Icons.phone),
              _buildDetailRow(
                  'Website', shop['website'] ?? 'N/A', Icons.language),
              const SizedBox(height: 12),
              if (shop['location'] != null) _buildLocationMap(shop['location']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMap(GeoPoint location) {
    // Safely extract the latitude and longitude from GeoPoint
    final double latitude = location.latitude;
    final double longitude = location.longitude;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pin_drop, color: Colors.blue.shade700, size: 16),
            const SizedBox(width: 8),
            Text(
              'Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(latitude, longitude),
                      child: const Icon(Icons.location_pin,
                          color: Colors.indigo, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNaiveUserDetails(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 0,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Location Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('State', user['state'], Icons.public),
              _buildDetailRow('District', user['district'], Icons.location_on),
              _buildDetailRow('Block', user['block'], Icons.map),
              _buildDetailRow('Office', user['office'], Icons.location_city),
            ],
          ),
        ),
      ),
    );
  }
}
