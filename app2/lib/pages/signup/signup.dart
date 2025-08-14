// import 'package:app2/pages/login/login.dart';
// import 'package:app2/services/auth_service.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Signup extends StatefulWidget {
//   const Signup({super.key});

//   @override
//   State<Signup> createState() => _SignupState();
// }

// class _SignupState extends State<Signup> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController =
//       TextEditingController();
//   final TextEditingController _profilePicController = TextEditingController();
//   final String _role = 'naive-user'; // Default role

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: true,
//         bottomNavigationBar: _signin(context),
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           toolbarHeight: 50,
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: Column(
//               children: [
//                 Center(
//                   child: Text(
//                     'Register Account',
//                     style: GoogleFonts.raleway(
//                         textStyle: const TextStyle(
//                             color: Colors.black,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 32)),
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 _name(),
//                 const SizedBox(height: 20),
//                 _emailAddress(),
//                 const SizedBox(height: 20),
//                 _phone(),
//                 const SizedBox(height: 20),
//                 _password(),
//                 const SizedBox(height: 20),
//                 _confirmPassword(),
//                 const SizedBox(height: 20),
//                 _profilePicLink(),
//                 const SizedBox(height: 50),
//                 _signup(context),
//               ],
//             ),
//           ),
//         ));
//   }

//   Widget _name() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Full Name',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _nameController,
//           decoration: InputDecoration(
//               filled: true,
//               hintText: 'John Doe',
//               hintStyle: const TextStyle(
//                   color: Color(0xff6A6A6A),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14),
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _emailAddress() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Email Address',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _emailController,
//           keyboardType: TextInputType.emailAddress,
//           decoration: InputDecoration(
//               filled: true,
//               hintText: 'sample@gmail.com',
//               hintStyle: const TextStyle(
//                   color: Color(0xff6A6A6A),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14),
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _phone() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Phone Number',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//               filled: true,
//               hintText: '+91 234 567 890',
//               hintStyle: const TextStyle(
//                   color: Color(0xff6A6A6A),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14),
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _password() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Password',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _passwordController,
//           obscureText: true,
//           decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _confirmPassword() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Confirm Password',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _confirmPasswordController,
//           obscureText: true,
//           decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _profilePicLink() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Profile Picture Link (Google Drive)',
//           style: GoogleFonts.raleway(
//               textStyle: const TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16)),
//         ),
//         const SizedBox(height: 16),
//         TextField(
//           controller: _profilePicController,
//           decoration: InputDecoration(
//               filled: true,
//               hintText: 'https://drive.google.com/...',
//               hintStyle: const TextStyle(
//                   color: Color(0xff6A6A6A),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 14),
//               fillColor: const Color(0xffF7F7F9),
//               border: OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                   borderRadius: BorderRadius.circular(14))),
//         )
//       ],
//     );
//   }

//   Widget _signup(BuildContext context) {
//     return ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: const Color(0xff0D6EFD),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         minimumSize: const Size(double.infinity, 60),
//         elevation: 0,
//       ),
//       onPressed: () async {
//         if (_passwordController.text != _confirmPasswordController.text) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Passwords do not match'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         await AuthService().signup(
//           name: _nameController.text,
//           email: _emailController.text,
//           phone: _phoneController.text,
//           password: _passwordController.text,
//           profilePicLink: _profilePicController.text,
//           role: _role,
//           context: context,
//         );
//       },
//       child: const Text("Sign Up",
//           style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.normal,
//               fontSize: 16)),
//     );
//   }

//   Widget _signin(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(children: [
//             const TextSpan(
//               text: "Already Have Account? ",
//               style: TextStyle(
//                   color: Color(0xff6A6A6A),
//                   fontWeight: FontWeight.normal,
//                   fontSize: 16),
//             ),
//             TextSpan(
//                 text: "Log In",
//                 style: const TextStyle(
//                     color: Color(0xff1A1D1E),
//                     fontWeight: FontWeight.normal,
//                     fontSize: 16),
//                 recognizer: TapGestureRecognizer()
//                   ..onTap = () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => Login()),
//                     );
//                   }),
//           ])),
//     );
//   }
// }
// 
// 
// 
// 
//  New code by claude
// 
// 
import 'package:app2/pages/login/login.dart';
import 'package:app2/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final String _role = 'naive-user'; // Default role
  
  // Colors for green theme
  final Color primaryColor = const Color(0xFF2E7D32); // Dark Green
  final Color accentColor = const Color(0xFF81C784);  // Light Green
  final Color bgColor = const Color(0xFFF5F5F5);      // Light Grey Background
  final Color fieldBgColor = Colors.white;            // White for text fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _signin(context),
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 4,
          title: Text('Create Account',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Register Account',
                        style: GoogleFonts.raleway(
                          textStyle: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _name(),
                const SizedBox(height: 16),
                _emailAddress(),
                const SizedBox(height: 16),
                _phone(),
                const SizedBox(height: 16),
                _password(),
                const SizedBox(height: 16),
                _confirmPassword(),
                const SizedBox(height: 16),
                _profilePicLink(),
                const SizedBox(height: 32),
                _signup(context),
              ],
            ),
          ),
        ));
  }

  Widget _name() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full Name',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                hintText: 'John Doe',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.person, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _emailAddress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Address',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                hintText: 'sample@gmail.com',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.email, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _phone() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phone Number',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                hintText: '+91 234 567 890',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.phone, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _password() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _confirmPassword() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Password',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _profilePicLink() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Picture Link ',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profilePicController,
              decoration: InputDecoration(
                filled: true,
                hintText: 'https://example.com/...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                fillColor: fieldBgColor,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.image, color: primaryColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _signup(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(double.infinity, 56),
            elevation: 0,
          ),
          onPressed: () async {
            if (_passwordController.text != _confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwords do not match'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            await AuthService().signup(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              password: _passwordController.text,
              profilePicLink: _profilePicController.text,
              role: _role,
              context: context,
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Sign Up",
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "Already Have Account? ",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: "Log In",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}