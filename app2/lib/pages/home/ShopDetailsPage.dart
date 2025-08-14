import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDetailsPage extends StatefulWidget {
  final Map<String, dynamic> shopData;

  const ShopDetailsPage({Key? key, required this.shopData}) : super(key: key);

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  late LatLng _shopLocation;

  @override
  void initState() {
    super.initState();
    // Ensure that widget.shopData['location'] is already a LatLng.
    _shopLocation = widget.shopData['location'];
  }

  // Updated _makePhoneCall method
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Clean the number (remove non-digits) and prepend +91
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final formattedNumber = '+91$cleanedNumber'; // Add country code
    final Uri launchUri = Uri.parse('tel:$formattedNumber');

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch dialer.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    try {
      // Clean and format the number with country code (e.g., +91)
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanedNumber.isEmpty) {
        throw 'Invalid phone number';
      }
      final formattedNumber = '+91$cleanedNumber'; // Include + for WhatsApp Web

      // Try native app first
      final nativeUri = Uri.parse('whatsapp://send?phone=$formattedNumber');
      final webUri = Uri.parse('https://wa.me/$formattedNumber');

      // Check if native app is installed
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to WhatsApp Web in Chrome/Browser
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // -------------------------------
          // Shop Header (Image & Name)
          // -------------------------------
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.shopData['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Image.network(
                widget.shopData['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ----------------------------------------------------------
          // Shop Details Card (Address, Website, & Contact Buttons)
          // ---------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address: ${widget.shopData['address']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.shopData['website'] != null &&
                          widget.shopData['website'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Website: ${widget.shopData['website']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: (widget
                                        .shopData['landline']?.isNotEmpty ??
                                    false)
                                ? () =>
                                    _makePhoneCall(widget.shopData['landline'])
                                : null,
                            icon: const Icon(Icons.phone),
                            label: const Text('Call'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: (widget
                                        .shopData['whatsapp']?.isNotEmpty ??
                                    false)
                                ? () =>
                                    _openWhatsApp(widget.shopData['whatsapp'])
                                : null,
                            icon: const Icon(Icons.message),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // -------------------------------
          // Products Grid (Cards)
          // -------------------------------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(widget.shopData['userId'])
                .collection('products')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final products = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product =
                          products[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(product['imageUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${product['price']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product['isAvailable']
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product['isAvailable']
                                            ? 'In Stock'
                                            : 'Out of Stock',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product['isAvailable']
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),

          // -------------------------------
          // Map Card (Now at the bottom)
          // -------------------------------
          SliverToBoxAdapter(
            child: Container(
              height: 300,
              margin: const EdgeInsets.all(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _shopLocation,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yourapp.name',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _shopLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
