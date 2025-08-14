import 'package:app2/pages/home/Govt_info.dart';
import 'package:app2/pages/home/Leaf_Scan.dart';
import 'package:app2/pages/home/Plant_Shop.dart';
import 'package:app2/pages/home/chatbot.dart';
import 'package:app2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app2/pages/home/profile.dart';
import 'package:app2/pages/home/shop_owner_form.dart';
import 'package:app2/pages/home/ShopProfilePage.dart';
import 'package:app2/pages/home/shopProductPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _pages = const [
    Govt_info(),
    Leaf_Scan(),
    Plant_Shop(),
  ];

  @override
  void initState() {
    super.initState();
    Gemini.init(
      apiKey: "Gemini_API_KEY",
    );
    _checkUserStatus();
  }

  // Check if user account is active
  void _checkUserStatus() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if user account is disabled
      if (userDoc.exists && userDoc.get('isActive') == false) {
        _showBlockedAccountAlert();
      }
      // Check if shop is disabled for shop owners
      else if (userDoc.exists &&
          userDoc.get('role') == 'shop-owner' &&
          userDoc.get('shopDetails')['isShopActive'] == false) {
        _showShopDisabledAlert();
      }
    } catch (e) {
      // Handle any errors
      print("Error checking user status: $e");
    }
  }

  // Show alert for blocked user accounts
  void _showBlockedAccountAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Blocked'),
          content: const Text(
            'Your account has been blocked by the admin. Please contact farmflow2025@gmail.com for further inquiry.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Log out after user clicks OK
                AuthService().signout(context: context);
              },
            ),
          ],
        );
      },
    );
  }

  // Show alert for disabled shops
  void _showShopDisabledAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Shop Disabled'),
          content: const Text(
            'Your shop has been disabled by the admin. Please contact farmflow2025@gmail.com for further inquiry.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: const Text('FarmFlow'),
        backgroundColor: const Color.fromARGB(255, 152, 183, 132),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Govt Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Scan Leaf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Plant Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
// In home.dart, update the FloatingActionButton
      floatingActionButton: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          String profileImage =
              "https://static.vecteezy.com/system/resources/previews/007/296/447/non_2x/user-icon-in-flat-style-person-icon-client-symbol-vector.jpg";
          if (snapshot.hasData) {
            profileImage = snapshot.data!.get('profilePicLink') as String;
          }
          return FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatbotPage(userProfileImage: profileImage),
                ),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.chat_rounded, color: Colors.white),
          );
        },
      ),
    );
  }
}

// NavigationDrawer remains the same as in original code
class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildHeader(context),
                buildMenuItems(context),
              ],
            ),
          ),
        ),
      );

  Widget buildHeader(BuildContext context) => FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          String name = "Loading...";
          String profilePic =
              "https://static.vecteezy.com/system/resources/previews/007/296/447/non_2x/user-icon-in-flat-style-person-icon-client-symbol-vector.jpg";

          if (snapshot.hasData) {
            name = snapshot.data!.get('name') as String;
            profilePic = snapshot.data!.get('profilePicLink') as String;
          }

          return Container(
            padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24,
            ),
            color: const Color.fromARGB(255, 26, 103, 30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundImage: NetworkImage(profilePic),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  FirebaseAuth.instance.currentUser!.email!,
                  style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          fontSize: 16)),
                ),
              ],
            ),
          );
        },
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            String role = snapshot.data?.get('role') ?? 'user';

            return Wrap(
              runSpacing: 16,
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                    );
                  },
                ),
                if (role != 'shop-owner')
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Become Shop Owner'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShopOwnerForm()),
                      );
                    },
                  ),
                if (role == 'shop-owner') ...[
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Shop Profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShopProfile()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag),
                    title: const Text('Shop Page'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShopPage()),
                      );
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Us'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report Bug'),
                  onTap: () async {
                    launchUrl(Uri.parse(
                        "mailto:farmflow2025@gmail.com?subject=Reporting a BUG in FarmFlow"));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Contact Us'),
                  onTap: () async {
                    launchUrl(Uri.parse(
                        "mailto:farmflow2025@gmail.com?subject=Enquiring about FarmFlow"));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await AuthService().signout(context: context);
                  },
                ),
              ],
            );
          },
        ),
      );
}
