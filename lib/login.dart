import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:vote_karo/AdminDashboard.dart';
import 'party.dart';
import 'election_page.dart'; // Your new ElectionsPage with OOP logic
import 'election.dart'; // Assuming your Election model is here
import 'candidate.dart'; // Assuming your Candidate model is here

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Election>> _loadElections() async {
    List<Election> elections = [];
    try {
      // Fetch elections from Firestore
      QuerySnapshot snapshot = await _firestore.collection('elections').get();
      for (var doc in snapshot.docs) {
        elections
            .add(Election.fromFirestore(doc)); // Use your fromFirestore method
      }
      if (elections.isEmpty) {
        print("No elections found.");
      } else {
        print("${elections.length} elections found.");
      }
    } catch (e) {
      print("Error fetching elections: $e");
    }
    return elections;
  }

  Future<void> signIn() async {
    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch the user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid) // Assuming user ID is the document ID
          .get();

      if (userDoc.exists) {
        // Check if the user is an admin
        bool isAdmin = userDoc['isAdmin'] ?? false;

        // Fetch the available elections from Firestore

        if (isAdmin) {
          // If the user is an admin, redirect to the Admin Page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboard(), // AdminPage
            ),
          );
        } else {
          // Otherwise, redirect to the ElectionsPage for regular users
          List<Election> elections = await _loadElections();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ElectionsPage(elections: elections),
            ),
          );
        }
      } else {
        throw Exception('User document not found.');
      }
    } catch (e) {
      // Handle specific errors for better user feedback
      String errorMessage = 'Login failed. Please check your credentials.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An unexpected error occurred.';
        }
      }
      // Show the error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home1.jpg'),
          fit: BoxFit.fitWidth,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(),
            Container(
              padding: const EdgeInsets.only(left: 45, top: 200),
              child: const Text(
                'BallotBox',
                style: TextStyle(
                  color: Color.fromRGBO(59, 47, 15, 1),
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      color: Color.fromRGBO(121, 200, 93, 0.4),
                      blurRadius: 4.0,
                      offset: Offset(6.0, 2.0),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          // Email TextField
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Password TextField
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Login Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 125,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Sign Up and Forgot Password Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, "/register");
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(20, 14),
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/forgot_password');
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(20, 14),
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                ),
                                child: const Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
