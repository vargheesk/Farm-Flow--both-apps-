import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminShopOwnersListPage extends StatefulWidget {
  @override
  _AdminShopOwnersListPageState createState() =>
      _AdminShopOwnersListPageState();
}

class _AdminShopOwnersListPageState extends State<AdminShopOwnersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  List<String> filterOptions = ['All', 'Active', 'Inactive'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Owners'),
        backgroundColor: Colors.lightGreen,
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by shop name or owner',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Filter Dropdown
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        icon: Icon(Icons.filter_list),
                        items: filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .where('role', isEqualTo: 'shop-owner')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No shop owners found'));
                }

                var shopOwners = snapshot.data!.docs;

                // Apply filters
                var filteredShopOwners = shopOwners.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  // Extract shopDetails
                  Map<String, dynamic> shopDetails = data['shopDetails'] ?? {};

                  // Apply search filter
                  bool matchesSearch = _searchQuery.isEmpty ||
                      (shopDetails['shopName']
                              ?.toString()
                              .toLowerCase()
                              .contains(_searchQuery) ??
                          false) ||
                      (data['name']
                              ?.toString()
                              .toLowerCase()
                              .contains(_searchQuery) ??
                          false);

                  // Apply active/inactive filter
                  bool matchesActiveFilter = _selectedFilter == 'All' ||
                      (_selectedFilter == 'Active' &&
                          (shopDetails['isShopActive'] == true)) ||
                      (_selectedFilter == 'Inactive' &&
                          (shopDetails['isShopActive'] == false));

                  return matchesSearch && matchesActiveFilter;
                }).toList();

                return filteredShopOwners.isEmpty
                    ? Center(child: Text('No matching shop owners found'))
                    : ListView.builder(
                        itemCount: filteredShopOwners.length,
                        itemBuilder: (context, index) {
                          var data = filteredShopOwners[index].data()
                              as Map<String, dynamic>;
                          var shopDetails = data['shopDetails'] ?? {};

                          var shopName =
                              shopDetails['shopName'] ?? 'Unknown Shop';
                          var ownerName = data['name'] ?? 'Unknown Owner';
                          var licenseNumber =
                              shopDetails['licenseNumber'] ?? 'N/A';
                          var shopAddress =
                              shopDetails['shopAddress'] ?? 'No Address';
                          var isActive = shopDetails['isShopActive'] ?? false;
                          var shopImageLink =
                              shopDetails['shopImageLink'] ?? '';

                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            elevation: 1,
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 60,
                                height: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: shopImageLink.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: shopImageLink,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.store,
                                                color: Colors.grey),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.error,
                                                color: Colors.grey),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: Icon(Icons.store,
                                              color: Colors.grey),
                                        ),
                                ),
                              ),
                              title: Text(
                                shopName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Owner: $ownerName'),
                                  Text(
                                    'License: $licenseNumber · $shopAddress',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.green.shade800
                                            : Colors.red.shade800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _toggleShopStatus(
                                        filteredShopOwners[index].id, isActive),
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.red.shade50
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        isActive
                                            ? Icons.block
                                            : Icons.check_circle,
                                        color: isActive
                                            ? Colors.red
                                            : Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showShopDetailsDialog(
                                  data, filteredShopOwners[index].id),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleShopStatus(String docId, bool currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(currentStatus ? 'Deactivate Shop?' : 'Activate Shop?'),
        content: Text(currentStatus
            ? 'Are you sure you want to deactivate this shop? The shop will no longer be visible to customers.'
            : 'Are you sure you want to activate this shop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('Users').doc(docId).update(
                  {'shopDetails.isShopActive': !currentStatus}).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(currentStatus
                        ? 'Shop deactivated successfully'
                        : 'Shop activated successfully'),
                    backgroundColor: currentStatus ? Colors.red : Colors.green,
                  ),
                );
                Navigator.pop(context);
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${error}'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              });
            },
            child: Text(currentStatus ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showShopDetailsDialog(Map<String, dynamic> userData, String shopId) {
    Map<String, dynamic> shopData = userData['shopDetails'] ?? {};
    bool isActive = shopData['isShopActive'] ?? false;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shop image header
              Container(
                height: 200,
                width: double.infinity,
                child: shopData['shopImageLink'] != null &&
                        shopData['shopImageLink'].toString().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: shopData['shopImageLink'],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Center(
                          child:
                              Icon(Icons.error, size: 50, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Center(
                          child:
                              Icon(Icons.store, size: 50, color: Colors.grey),
                        ),
                      ),
              ),

              // Shop name and status indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shopData['shopName'] ?? 'Unknown Shop',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shop details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Owner', userData['name'] ?? 'Unknown'),
                    _buildDetailRow('Phone', userData['phone'] ?? 'N/A'),
                    _buildDetailRow(
                        'WhatsApp', shopData['whatsappNumber'] ?? 'N/A'),
                    _buildDetailRow('Email', userData['email'] ?? 'N/A'),
                    _buildDetailRow(
                        'License', shopData['licenseNumber'] ?? 'N/A'),
                    _buildDetailRow(
                        'Aadhaar', shopData['aadharNumber'] ?? 'N/A'),
                    _buildDetailRow(
                        'Address', shopData['shopAddress'] ?? 'N/A'),
                    if (shopData['location'] != null)
                      _buildDetailRow(
                          'Location', shopData['location'].toString()),
                    _buildDetailRow('District', userData['district'] ?? 'N/A'),
                    _buildDetailRow('State', userData['state'] ?? 'N/A'),
                    _buildDetailRow(
                        'Landline', shopData['landlineNumber'] ?? 'N/A'),
                    _buildDetailRow('Website', shopData['website'] ?? 'N/A'),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleShopStatus(shopId, isActive);
                      },
                      child:
                          Text(isActive ? 'Deactivate Shop' : 'Activate Shop'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
