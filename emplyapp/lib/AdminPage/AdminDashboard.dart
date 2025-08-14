import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'GovtEmployeesListPage.dart'; // Add this at the top
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'NaiveUsersListPage.dart';
import 'ShopOwnersListPage.dart';
import 'TotalUsersListPage.dart';
import 'AdminShopOwnersListPage.dart';
// Import other list pages as needed

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _employeeManagementKey = GlobalKey();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _userTypeCounts = {};
  Map<String, int> _announcementsByState = {};
  Map<String, int> _usersByDistrict = {};
  Map<String, int> _shopOwnersByDistrict = {};
  Map<String, Map<String, int>> _topDistrictsByAnnouncements = {};
  Map<String, Map<String, int>> _usersByDistrictByRole = {};
  bool _isLoading = true;
  int _pendingVerifications = 0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final usersSnapshot = await _firestore.collection('Users').get();
      final Map<String, int> userTypes = {};
      int pendingCount = 0;

      // Maps for tracking users and shop owners by district
      Map<String, int> usersByDistrict = {};
      Map<String, int> shopOwnersByDistrict = {};

      // Initialize map for tracking users by district and role
      Map<String, Map<String, int>> districtRoleCounts = {};

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String? ?? 'unknown';
        final district = data['district'] as String? ?? 'unknown';

        if (role != 'admin') {
          userTypes[role] = (userTypes[role] ?? 0) + 1;

          // ========== MODIFIED SECTION ========== //
          // Track ONLY NAIVE-USERS by district
          if (role == 'naive-user') {
            usersByDistrict[district] = (usersByDistrict[district] ?? 0) + 1;
          }
          // ========== END MODIFICATION ========== //

          // Track shop owners by district
          if (role == 'shop-owner') {
            shopOwnersByDistrict[district] =
                (shopOwnersByDistrict[district] ?? 0) + 1;
          }

          // Track users by district and role
          if (!districtRoleCounts.containsKey(district)) {
            districtRoleCounts[district] = {
              'naive-user': 0,
              'shop-owner': 0,
              'govt_employee': 0
            };
          }

          if (role == 'naive-user') {
            districtRoleCounts[district]!['naive-user'] =
                (districtRoleCounts[district]!['naive-user'] ?? 0) + 1;
          } else if (role == 'shop-owner') {
            districtRoleCounts[district]!['shop-owner'] =
                (districtRoleCounts[district]!['shop-owner'] ?? 0) + 1;
          } else if (role == 'govt_employee') {
            districtRoleCounts[district]!['govt_employee'] =
                (districtRoleCounts[district]!['govt_employee'] ?? 0) + 1;
          }
        }

        if (role == 'govt_employee' && !(data['isVerified'] ?? false)) {
          pendingCount++;
        }
      }

      // Load announcement data by state
      final Map<String, int> stateAnnouncements = {};
      final govtEmployees = usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'govt_employee');

      // For district announcements tracking
      final Map<String, Map<String, int>> districtAnnouncementsByState = {};

      for (var employee in govtEmployees) {
        final employeeData = employee.data();
        final state = employeeData['state'] as String? ?? 'unknown';
        final district = employeeData['district'] as String? ?? 'unknown';

        final announcementsSnapshot = await _firestore
            .collection('Users')
            .doc(employee.id)
            .collection('Announcement')
            .get();

        final announcementCount = announcementsSnapshot.docs.length;

        if (announcementCount > 0) {
          // Update state count
          stateAnnouncements[state] =
              (stateAnnouncements[state] ?? 0) + announcementCount;

          // Update district count
          if (!districtAnnouncementsByState.containsKey(state)) {
            districtAnnouncementsByState[state] = {};
          }

          districtAnnouncementsByState[state]![district] =
              (districtAnnouncementsByState[state]![district] ?? 0) +
                  announcementCount;
        }
      }

      setState(() {
        _userTypeCounts = userTypes;
        _usersByDistrictByRole = districtRoleCounts;
        _announcementsByState = stateAnnouncements;
        _topDistrictsByAnnouncements = districtAnnouncementsByState;
        _pendingVerifications = pendingCount;
        _usersByDistrict = usersByDistrict;
        _shopOwnersByDistrict = shopOwnersByDistrict;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate total users excluding admin
    final totalUsers =
        _userTypeCounts.values.fold(0, (sum, count) => sum + count);

    return RefreshIndicator(
      onRefresh: _loadAnalyticsData,
      child: SingleChildScrollView(
        controller: _scrollController, // Add this line
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to the Farmflow Admin Dashboard!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // In build method of _AdminDashboardState
// Replace all Row widgets with this:

            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                int crossAxisCount;

                if (screenWidth > 1200) {
                  crossAxisCount = 4; // Large screens (e.g., tablets/desktops)
                } else if (screenWidth > 800) {
                  crossAxisCount = 4; // Medium screens
                } else if (screenWidth > 600) {
                  crossAxisCount = 3; // Small tablets
                } else {
                  crossAxisCount = 2; // Phones (single column)
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.4, // Adjust aspect ratio for card height
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 8,
                  children: [
// In the GridView children array:
                    _buildAnalyticsCard(
                      'Total Users',
                      totalUsers,
                      Icons.people,
                      Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TotalUsersListPage()),
                      ),
                    ),
                    _buildAnalyticsCard(
                      'Govt Employees',
                      _userTypeCounts['govt_employee'] ?? 0,
                      Icons.work,
                      Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GovtEmployeesListPage()),
                      ),
                    ),
                    _buildAnalyticsCard(
                      'Naive Users',
                      _userTypeCounts['naive-user'] ?? 0,
                      Icons.person,
                      Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NaiveUsersListPage()),
                      ),
                    ),
// Original Shop Owners card (keep this if you want both)
                    _buildAnalyticsCard(
                      'Shop Owners',
                      _userTypeCounts['shop-owner'] ?? 0,
                      Icons.store,
                      Colors.amber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShopOwnersListPage()),
                      ),
                    ),

// New Total Shops card
                    _buildAnalyticsCard(
                      'Total Shops',
                      _userTypeCounts['shop-owner'] ?? 0,
                      Icons.shopping_bag,
                      Colors.lightGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminShopOwnersListPage()),
                      ),
                    ),
                    _buildAnalyticsCard(
                      'Pending Verifications',
                      _pendingVerifications,
                      Icons.verified_user,
                      Colors.red,
                    ),
                  ],
                );
              },
            ),

            /////////////////////////////////////////////////////////////////////////////////
            /// **Why Rows Instead of GridView?**
            /// - **Custom Spacing**: Needed variable gaps (e.g., 24px vs 16px) between rows.
            /// - **Fixed Items**: Small, fixed number of cards (no dynamic loading).
            /// - **Readability**: Explicit Rows + SizedBox make layout intent clearer.
            ///
            /// GridView would add unnecessary overhead for this static layout.
            //////////////////////////////////////////////////////////////////////////////////

            // GridView.count(
            //   shrinkWrap: true,
            //   physics: NeverScrollableScrollPhysics(),
            //   crossAxisCount: 2,
            //   childAspectRatio: 2.2,
            //   crossAxisSpacing: 16.0,
            //   mainAxisSpacing: 16.0,
            //   children: [
            //     _buildAnalyticsCard(
            //       'Total Users',
            //       totalUsers,
            //       Icons.people,
            //       Colors.blue,
            //     ),
            //     _buildAnalyticsCard(
            //       'Govt Employees',
            //       _userTypeCounts['govt_employee'] ?? 0,
            //       Icons.work,
            //       Colors.green,
            //     ),
            //     _buildAnalyticsCard(
            //       'Naive Users',
            //       _userTypeCounts['naive-user'] ?? 0,
            //       Icons.person,
            //       Colors.purple,
            //     ),
            //     _buildAnalyticsCard(
            //       'Shop Owners',
            //       _userTypeCounts['shop-owner'] ?? 0,
            //       Icons.store,
            //       Colors.amber,
            //     ),
            //     _buildAnalyticsCard(
            //       'Total Announcements',
            //       _announcementsByState.values
            //           .fold(0, (sum, count) => sum + count),
            //       Icons.campaign,
            //       Colors.orange,
            //     ),
            //     _buildAnalyticsCard(
            //       'Pending Verifications',
            //       _pendingVerifications,
            //       Icons.verified_user,
            //       Colors.red,
            //     ),
            //   ],
            // ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220,
                      width: double.infinity,
                      child: _buildUserTypeChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 24),
            // Card(
            //   elevation: 4,
            //   child: Padding(
            //     padding: const EdgeInsets.all(16),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         const Text(
            //           'Top Districts by Announcements',
            //           style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         const SizedBox(height: 16),
            //         Container(
            //           height: 250,
            //           width: double.infinity,
            //           child: _buildTopDistrictsChart(),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Users by District',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      width: double.infinity,
                      child: _buildUsersByDistrictChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shop Owners by District',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 250,
                      width: double.infinity,
                      child: _buildShopOwnersByDistrictChart(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              key: _employeeManagementKey, // <-- Add here
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Employee Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmployeeManagementSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToVerificationSection() {
    final context = _employeeManagementKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildAnalyticsCard(
    String title,
    int value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeChart() {
    if (_userTypeCounts.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final entries = _userTypeCounts.entries.toList();

    return PieChart(
      PieChartData(
        sections: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return PieChartSectionData(
            color: _getColorForIndex(index),
            value: item.value.toDouble(),
            title: '${_formatRoleLabel(item.key)}\n${item.value}',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: -90,
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // Widget _buildTopDistrictsChart() {
  //   // Convert the nested map into a flat list of district-count pairs
  //   final List<MapEntry<String, int>> allDistricts = [];

  //   _topDistrictsByAnnouncements.forEach((state, districts) {
  //     districts.forEach((district, count) {
  //       allDistricts.add(MapEntry('$district ($state)', count));
  //     });
  //   });

  //   // Sort by count (descending) and take top 10
  //   allDistricts.sort((a, b) => b.value.compareTo(a.value));
  //   final topDistricts = allDistricts.take(10).toList();

  //   if (topDistricts.isEmpty) {
  //     return const Center(child: Text('No data available'));
  //   }

  //   return BarChart(
  //     BarChartData(
  //       alignment: BarChartAlignment.spaceAround,
  //       maxY: (topDistricts.first.value * 1.2).toDouble(),
  //       barTouchData: BarTouchData(
  //         touchTooltipData: BarTouchTooltipData(
  //           tooltipBgColor: Colors.blueGrey,
  //           getTooltipItem: (group, groupIndex, rod, rodIndex) {
  //             if (groupIndex >= topDistricts.length) return null;
  //             return BarTooltipItem(
  //               '${topDistricts[groupIndex].key}: ${topDistricts[groupIndex].value}',
  //               const TextStyle(color: Colors.white),
  //             );
  //           },
  //         ),
  //       ),
  //       titlesData: FlTitlesData(
  //         show: true,
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               if (value < 0 || value >= topDistricts.length)
  //                 return const Text('');
  //               final districtName =
  //                   topDistricts[value.toInt()].key.split(' (')[0];
  //               return Padding(
  //                 padding: const EdgeInsets.only(top: 8.0),
  //                 child: Text(
  //                   districtName,
  //                   style: const TextStyle(
  //                     color: Colors.black,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 9,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               );
  //             },
  //             reservedSize: 30,
  //           ),
  //         ),
  //         leftTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               return Text(
  //                 value.toInt().toString(),
  //                 style: const TextStyle(
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 10,
  //                 ),
  //               );
  //             },
  //             reservedSize: 30,
  //           ),
  //         ),
  //         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //       ),
  //       borderData: FlBorderData(
  //         show: true,
  //         border: Border.all(color: Colors.grey.shade300),
  //       ),
  //       barGroups: topDistricts.asMap().entries.map((entry) {
  //         final index = entry.key;
  //         final item = entry.value;
  //         return BarChartGroupData(
  //           x: index,
  //           barRods: [
  //             BarChartRodData(
  //               toY: item.value.toDouble(),
  //               color: Colors.green,
  //               width: 20,
  //               borderRadius: const BorderRadius.only(
  //                 topLeft: Radius.circular(4),
  //                 topRight: Radius.circular(4),
  //               ),
  //             ),
  //           ],
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget _buildUsersByDistrictChart() {
    if (_usersByDistrict.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sortedEntries = _usersByDistrict.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDistricts = sortedEntries.take(10).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (topDistricts.first.value * 1.2).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= topDistricts.length) return null;
              return BarTooltipItem(
                '${topDistricts[groupIndex].key}: ${topDistricts[groupIndex].value}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= topDistricts.length)
                  return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    topDistricts[value.toInt()].key,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: topDistricts.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value.toDouble(),
                color: Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShopOwnersByDistrictChart() {
    if (_shopOwnersByDistrict.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sortedEntries = _shopOwnersByDistrict.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topDistricts = sortedEntries.take(10).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (topDistricts.isNotEmpty ? topDistricts.first.value * 1.2 : 1)
            .toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= topDistricts.length) return null;
              return BarTooltipItem(
                '${topDistricts[groupIndex].key}: ${topDistricts[groupIndex].value}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= topDistricts.length)
                  return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    topDistricts[value.toInt()].key,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: topDistricts.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value.toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeeManagementSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Users')
          .where('role', isEqualTo: 'govt_employee')
          .where('isVerified', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No pending verification requests')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              elevation: 2,
              child: InkWell(
                onTap: () => _showEmployeeDetailDialog(
                    context, users[index].id, userData),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          image: userData['profilePicLink'] != null &&
                                  userData['profilePicLink']
                                      .toString()
                                      .isNotEmpty
                              ? DecorationImage(
                                  image:
                                      NetworkImage(userData['profilePicLink']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: userData['profilePicLink'] == null ||
                                userData['profilePicLink'].toString().isEmpty
                            ? const Icon(Icons.person,
                                size: 30, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      // Employee information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${userData['office'] ?? 'N/A'}, ${userData['block'] ?? 'N/A'}, ${userData['district'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${userData['employeeId'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Verify button
                      IconButton(
                        icon: const Icon(Icons.verified_user,
                            color: Colors.green),
                        tooltip: 'Verified',
                        onPressed: () => _verifyEmployee(users[index].id),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEmployeeDetailDialog(
      BuildContext context, String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Row(
                  children: [
                    const Text(
                      'Employee Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 36,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Profile picture and name in same row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Square profile picture with X placeholder

                    Container(
                      width: 100, // Increased size
                      height: 100, // Increased size
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16), // More curved
                        image: userData['profilePicLink'] != null &&
                                userData['profilePicLink'].toString().isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(userData['profilePicLink']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (userData['profilePicLink'] == null ||
                              userData['profilePicLink'].toString().isEmpty)
                          ? const Icon(Icons.close,
                              size: 60, // Larger icon size
                              color: Colors.black)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Name
                    Text(
                      userData['name'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Employee ID, Email, Phone stack vertically
                const SizedBox(height: 8),
                Column(
                  children: [
                    _buildInlineDetailRow(
                        'ID', userData['employeeId'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInlineDetailRow('Email', userData['email'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInlineDetailRow('Phone', userData['phone'] ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Location details
                const Text(
                  'Office Information',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    _buildInlineDetailRow(
                        'Office', userData['office'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInlineDetailRow('Block', userData['block'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInlineDetailRow(
                        'District', userData['district'] ?? 'N/A'),
                    const SizedBox(height: 4),
                    _buildInlineDetailRow('State', userData['state'] ?? 'N/A'),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // ID Verification
                if (userData['aadhar'] != null)
                  _buildInlineDetailRow(
                    'Aadhar No',
                    '${userData['aadhar'].toString().substring(0, 4)}-XXXX-XXXX',
                  ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          textStyle: const TextStyle(fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: Colors.red.shade300),
                          ),
                        ),
                        onPressed: () => _showRejectReasonDialog(
                            context, userId, userData['email']),
                        child: const Text('Recject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          _verifyEmployee(userId);
                          Navigator.pop(context);
                        },
                        child: const Text('Verified'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  void _showRejectReasonDialog(
      BuildContext context, String userId, String? userEmail) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Please provide a reason for not verifying this employee:'),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason',
                  labelText: 'Reason',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_reasonController.text.trim().isNotEmpty) {
                  _sendRejectionEmail(
                      userId, userEmail, _reasonController.text);
                  Navigator.pop(context); // Close reason dialog
                  Navigator.pop(context); // Close details dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendRejectionEmail(
      String userId, String? userEmail, String reason) async {
    try {
      // First, update the user status in Firestore (optional)
      await _firestore.collection('Users').doc(userId).update({
        'verificationRejected': true,
        'rejectionReason': reason,
        'rejectionTimestamp': FieldValue.serverTimestamp(),
      });

      // Call your email sending function or Cloud Function
      final result = await _firestore.collection('mail').add({
        'to': userEmail,
        'cc': 'farmflow2025@gmail.com',
        'message': {
          'subject': 'Verification Update - FarmFlow',
          'text':
              'We regret to inform you that we are unable to verify your account at this time. Reason: $reason\n\nPlease contact support if you believe this is an error.',
          'html': '''
          <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
            <h2>Verification Update - FarmFlow</h2>
            <p>Dear User,</p>
            <p>We regret to inform you that we are unable to verify your account at this time.</p>
            <p><strong>Reason:</strong> $reason</p>
            <p>Please contact support if you believe this is an error or if you need further assistance.</p>
            <p>Regards,<br>FarmFlow Admin Team</p>
          </div>
        ''',
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rejection notification sent successfully'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print('Error sending rejection email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending rejection notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update the existing _verifyEmployee method to show a toast notification
  Future<void> _verifyEmployee(String userId) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'isVerified': true,
        'verificationTimestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee verified successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data after verification
      _loadAnalyticsData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error verifying employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _toggleUserStatus(String id, bool bool) {}
  // ... rest of existing methods below ...
  String _formatRoleLabel(String role) {
    return role
        .split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
