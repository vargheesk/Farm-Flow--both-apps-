import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this package to your pubspec.yaml

class GovtEmployeesListPage extends StatefulWidget {
  const GovtEmployeesListPage({Key? key}) : super(key: key);

  @override
  State<GovtEmployeesListPage> createState() => _GovtEmployeesListPageState();
}

class _GovtEmployeesListPageState extends State<GovtEmployeesListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  String _searchQuery = '';
  String _filterState = 'All';
  String _filterDistrict = 'All';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: 'govt_employee')
          .get();

      _employees = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort employees by verification status (verified first)
      _employees.sort((a, b) {
        final aVerified = a['isVerified'] ?? false;
        final bVerified = b['isVerified'] ?? false;

        if (aVerified == bVerified) {
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        }
        return aVerified ? -1 : 1;
      });

      _filteredEmployees = List.from(_employees);
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading employees: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        // Filter by search query
        final name = (employee['name'] ?? '').toLowerCase();
        final email = (employee['email'] ?? '').toLowerCase();
        final employeeId = (employee['employeeId'] ?? '').toLowerCase();
        final office = (employee['office'] ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        bool matchesSearch = query.isEmpty ||
            name.contains(query) ||
            email.contains(query) ||
            employeeId.contains(query) ||
            office.contains(query);

        // Filter by state
        bool matchesState =
            _filterState == 'All' || employee['state'] == _filterState;

        // Filter by district
        bool matchesDistrict =
            _filterDistrict == 'All' || employee['district'] == _filterDistrict;

        return matchesSearch && matchesState && matchesDistrict;
      }).toList();
    });
  }

  List<String> _getAvailableStates() {
    final states = _employees
        .map((e) => e['state'] as String?)
        .where((e) => e != null)
        .cast<String>() // Properly cast non-nullable strings
        .toSet()
        .toList();
    states.sort();
    return ['All', ...states];
  }

  List<String> _getAvailableDistricts() {
    final districts = _employees
        .where((e) => _filterState == 'All' || e['state'] == _filterState)
        .map((e) => e['district'] as String?)
        .where((e) => e != null)
        .cast<String>() // Properly cast non-nullable strings
        .toSet()
        .toList();
    districts.sort();
    return ['All', ...districts];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Employees'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.filter_list),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : _buildEmployeesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade700,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name, email, or ID',
            prefixIcon: const Icon(Icons.search, color: Colors.green),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _filterEmployees();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filterEmployees();
            });
          },
        ),
      ),
    );
  }

  Widget _buildEmployeesList() {
    if (_filteredEmployees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      color: Colors.green.shade700,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredEmployees.length,
        itemBuilder: (context, index) {
          final employee = _filteredEmployees[index];
          final isVerified = employee['isVerified'] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    isVerified ? Colors.green.shade200 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showEmployeeDetails(employee),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildEmployeeAvatar(employee),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  employee['name'] ?? 'Anonymous',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildVerificationBadge(isVerified),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            employee['email'] ?? 'No email',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.badge,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                employee['employeeId'] ?? 'No ID',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_city,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${employee['office'] ?? 'N/A'}, ${employee['district'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeAvatar(Map<String, dynamic> employee) {
    return Hero(
      tag: 'avatar-${employee['id']}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: (employee['isVerified'] ?? false)
                ? Colors.green.shade300
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: employee['profilePicLink'] != null &&
                  employee['profilePicLink'].isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: employee['profilePicLink'],
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Removed const keyword
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 12,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.green.shade700),
                      const SizedBox(width: 10),
                      Text(
                        'Filter Employees',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _filterState = 'All';
                            _filterDistrict = 'All';
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'State',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterState,
                        isExpanded: true,
                        items: _getAvailableStates().map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setModalState(() {
                              _filterState = newValue;
                              _filterDistrict = 'All';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'District',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterDistrict,
                        isExpanded: true,
                        items: _getAvailableDistricts().map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setModalState(() {
                              _filterDistrict = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _filterEmployees();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEmployeeDetails(Map<String, dynamic> employee) {
    final bool isVerified = employee['isVerified'] ?? false;
    final bool isActive = employee['isActive'] ?? false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // Making the dialog wider
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width:
              double.infinity, // Use maximum width available within constraints
          constraints: const BoxConstraints(maxWidth: 500), // Set maximum width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Employee Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Make the content scrollable
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (employee['profilePicLink'] != null &&
                            employee['profilePicLink'].isNotEmpty)
                          Hero(
                            tag: 'avatar-${employee['id']}',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isVerified
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(employee['profilePicLink']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else
                          Hero(
                            tag: 'avatar-${employee['id']}',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade200,
                                border: Border.all(
                                  color: isVerified
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(Icons.person,
                                  size: 60, color: Colors.grey),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          employee['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee['employeeId'] ?? 'No ID',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatusChip(
                              isVerified ? 'Verified' : 'Pending',
                              isVerified ? Colors.green : Colors.orange,
                              isVerified ? Icons.verified : Icons.pending,
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              isActive ? 'Active' : 'Inactive',
                              isActive ? Colors.blue : Colors.red,
                              isActive ? Icons.check_circle : Icons.cancel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Make detail rows more compact
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('Email',
                                  employee['email'] ?? 'N/A', Icons.email,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow('Phone',
                                  employee['phone'] ?? 'N/A', Icons.phone,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow(
                                  'Aadhar',
                                  employee['aadhar'] ?? 'N/A',
                                  Icons.credit_card,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow(
                                  'Office',
                                  employee['office'] ?? 'N/A',
                                  Icons.location_city,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow('Block',
                                  employee['block'] ?? 'N/A', Icons.grid_view,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow(
                                  'District',
                                  employee['district'] ?? 'N/A',
                                  Icons.location_on,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow('State',
                                  employee['state'] ?? 'N/A', Icons.map,
                                  compact: true),
                              _buildDivider(),
                              _buildDetailRow(
                                'Joined',
                                employee['createdAt'] != null
                                    ? _formatTimestamp(employee['createdAt'])
                                    : 'N/A',
                                Icons.calendar_today,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Messaging feature coming soon')),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Edit feature coming soon')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 8 : 12,
      ),
      child: Row(
        children: [
          Icon(icon, size: compact ? 18 : 20, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: compact ? 1 : 2), // Removed const
                Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }
}
