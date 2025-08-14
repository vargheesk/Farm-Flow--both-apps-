import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopOwnersListPage extends StatefulWidget {
  const ShopOwnersListPage({Key? key}) : super(key: key);

  @override
  State<ShopOwnersListPage> createState() => _ShopOwnersListPageState();
}

class _ShopOwnersListPageState extends State<ShopOwnersListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _shopOwners = [];

  @override
  void initState() {
    super.initState();
    _loadShopOwners();
  }

  Future<void> _loadShopOwners() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await _firestore
          .collection('Users')
          .where('role', isEqualTo: 'shop-owner')
          .get();
          
      final shopOwners = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
      
      setState(() {
        _shopOwners = shopOwners;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading shop owners: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Owners'),
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadShopOwners,
              child: _shopOwners.isEmpty
                  ? const Center(child: Text('No shop owners found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _shopOwners.length,
                      itemBuilder: (context, index) {
                        final shopOwner = _shopOwners[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: shopOwner['profilePicLink'] != null &&
                                      shopOwner['profilePicLink'].toString().isNotEmpty
                                  ? NetworkImage(shopOwner['profilePicLink'])
                                  : null,
                              child: shopOwner['profilePicLink'] == null ||
                                      shopOwner['profilePicLink'].toString().isEmpty
                                  ? const Icon(Icons.store)
                                  : null,
                            ),
                            title: Text(shopOwner['shopName'] ?? shopOwner['name'] ?? 'Anonymous Shop'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shopOwner['email'] ?? 'No email'),
                                if (shopOwner['district'] != null)
                                  Text('District: ${shopOwner['district']}'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              // Show shop owner details or navigate to detail page
                              _showShopOwnerDetails(shopOwner);
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showShopOwnerDetails(Map<String, dynamic> shopOwner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shop Owner Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (shopOwner['profilePicLink'] != null &&
                  shopOwner['profilePicLink'].toString().isNotEmpty)
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(shopOwner['profilePicLink']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Shop Name', shopOwner['shopName'] ?? 'N/A'),
              _buildDetailRow('Owner Name', shopOwner['name'] ?? 'N/A'),
              _buildDetailRow('Email', shopOwner['email'] ?? 'N/A'),
              _buildDetailRow('Phone', shopOwner['phone'] ?? 'N/A'),
              _buildDetailRow('Shop Type', shopOwner['shopType'] ?? 'N/A'),
              _buildDetailRow('District', shopOwner['district'] ?? 'N/A'),
              _buildDetailRow('State', shopOwner['state'] ?? 'N/A'),
              _buildDetailRow('Address', shopOwner['address'] ?? 'N/A'),
              _buildDetailRow('Joined', shopOwner['createdAt'] != null
                  ? _formatTimestamp(shopOwner['createdAt'])
                  : 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value)),
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