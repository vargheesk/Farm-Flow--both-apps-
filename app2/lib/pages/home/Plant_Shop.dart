import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app2/pages/home/geoapify_location_picker.dart';
import 'package:app2/pages/home/ShopDetailsPage.dart';

class Plant_Shop extends StatefulWidget {
  const Plant_Shop({super.key});

  @override
  State<Plant_Shop> createState() => _Plant_ShopState();
}

class _Plant_ShopState extends State<Plant_Shop> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredShops = [];
  LatLng? _currentLocation;
  bool _isLoading = false;
  List<Map<String, dynamic>> allShops = [];
  // Add a refresh controller
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
    _fetchShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchShops() async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot shopSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('role', isEqualTo: 'shop-owner')
          .get();

      allShops = shopSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final shopDetails = data['shopDetails'] as Map<String, dynamic>;
        final location = shopDetails['location'] as GeoPoint;

        return {
          'userId': doc.id,
          'name': shopDetails['shopName'],
          'address': shopDetails['shopAddress'],
          'imageUrl': shopDetails['shopImageLink'],
          'location': LatLng(location.latitude, location.longitude),
          'whatsapp': shopDetails['whatsappNumber'],
          'landline': shopDetails['landlineNumber'],
          'website': shopDetails['website'],
        };
      }).toList();

      if (_currentLocation != null) {
        await _sortShopsByTravelTime();
      } else {
        setState(() => filteredShops = allShops);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching shops: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Implement refresh function that will be called on pull-to-refresh
  Future<void> _refreshData() async {
    await _getCurrentLocation();
    await _fetchShops();
    return Future.value();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (allShops.isNotEmpty) {
        await _sortShopsByTravelTime();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sortShopsByTravelTime() async {
    if (_currentLocation == null || allShops.isEmpty) return;

    try {
      // Prepare sources and destinations for the API
      List<Map<String, double>> sources = [
        {'lat': _currentLocation!.latitude, 'lon': _currentLocation!.longitude}
      ];

      List<Map<String, double>> destinations = allShops
          .map((shop) => {
                'lat': (shop['location'].latitude as double),
                'lon': (shop['location'].longitude as double)
              })
          .toList();

      // Call Geoapify Route Matrix API
      final response = await http.post(
        Uri.parse(
            'https://api.geoapify.com/v1/routematrix?apiKey=d9a5eb3df75b4e3b8d1c4c90ba8922f8'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mode': 'drive',
          'sources': sources,
          'destinations': destinations,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final times = data['sources_to_destinations'][0];

        // Add travel time to shops and sort
        List<Map<String, dynamic>> shopsWithTime = List.from(allShops);
        for (int i = 0; i < shopsWithTime.length; i++) {
          shopsWithTime[i]['travelTime'] = times[i];
        }

        shopsWithTime.sort((a, b) =>
            (a['travelTime'] as num).compareTo(b['travelTime'] as num));

        setState(() => filteredShops = shopsWithTime);
      } else {
        throw Exception('Failed to get route matrix');
      }
    } catch (e) {
      // Fallback to direct distance sorting
      List<Map<String, dynamic>> sortedShops = List.from(allShops);
      sortedShops.sort((a, b) {
        double distA = _calculateDistance(_currentLocation!, a['location']);
        double distB = _calculateDistance(_currentLocation!, b['location']);
        return distA.compareTo(distB);
      });
      setState(() => filteredShops = sortedShops);
    }
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredShops = allShops.where((shop) {
        return shop['name'].toLowerCase().contains(searchTerm) ||
            shop['address'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use Current Location'),
              onTap: () {
                Navigator.pop(context);
                _getCurrentLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Choose on Map'),
              onTap: () {
                Navigator.pop(context);
                _openLocationPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    final LatLng? pickedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GeoapifyLocationPicker()),
    );

    if (pickedLocation != null) {
      setState(() {
        _currentLocation = pickedLocation;
      });
      await _sortShopsByTravelTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 170, 191, 163),
          child: Column(
            children: [
              // Header Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Plant Shops',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 19, 40, 20),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _showLocationDialog,
                          color: const Color.fromARGB(255, 26, 103, 30),
                        ),
                      ],
                    ),
                    if (_currentLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(
                          'Showing shops near: ${_currentLocation!.latitude.toStringAsFixed(4)}, ${_currentLocation!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 26, 103, 30),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search shops by name or address',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // Shop Grid with RefreshIndicator
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        key: _refreshKey,
                        onRefresh: _refreshData,
                        color: const Color.fromARGB(255, 26, 103, 30),
                        child: filteredShops.isEmpty
                            ? ListView(
                                // Using ListView instead of Center for RefreshIndicator to work
                                children: const [
                                  SizedBox(height: 100),
                                  Center(
                                    child: Text(
                                      'No shops found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: filteredShops.length,
                                itemBuilder: (context, index) {
                                  final shop = filteredShops[index];
                                  double? distance = _currentLocation != null
                                      ? _calculateDistance(
                                          _currentLocation!, shop['location'])
                                      : null;

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShopDetailsPage(
                                            shopData: {
                                              'name': shop['name'],
                                              'address': shop['address'],
                                              'imageUrl': shop['imageUrl'],
                                              'location': shop['location'],
                                              'landline': shop['landline'],
                                              'whatsapp': shop['whatsapp'],
                                              'website': shop['website'],
                                              'distance': distance,
                                              'userId': shop['userId'],
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Shop Image
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              width: double.infinity,
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                  top: Radius.circular(12),
                                                ),
                                                child: Image.network(
                                                  shop['imageUrl'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[50],
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: const Icon(
                                                          Icons.error,
                                                          color: Colors.black),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Shop Details
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  shop['name'],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  shop['address'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (distance != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8),
                                                    child: Text(
                                                      '${(distance / 1000).toStringAsFixed(1)} km away',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
