import 'dart:ffi';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vote_karo/firebase_options.dart';
import 'package:vote_karo/login.dart';
import 'package:vote_karo/register.dart';
// import 'package:vote_karo/login.dart';
// import 'package:vote_karo/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialPage(),
        '/login':(context) => const MyLogin(),
        '/register':(context) => const MyRegister(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => NotFoundPage());
      },
    );
  }
}

class NotFoundPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class InitialPage extends StatelessWidget{
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
    body: SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration:const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white70, Colors.lightBlueAccent],  // Start and end colors of the gradient
            begin: Alignment.topLeft,  // Starting point of the gradient
            end: Alignment.bottomRight,  // Ending point of the gradient
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child:Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image.asset(
                    'assets/voting_homepage.png',
                    height:250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                ),
                ),

              ],
            ),),
            const Text(
              'BallotBox',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
           const Text(
               'The Future of Voting is in Your Hands—BallotBox.',
           style: TextStyle(
             fontSize: 20,
              color: Color.fromRGBO(1, 13, 30, 56),
              fontWeight: FontWeight.bold,
            ),
             textAlign: TextAlign.center,
           ),
           const Text(
             'Forget to stay in long queues, paperwork and methods. Vote now using BallotBox from your mobile.',
             style: TextStyle(
               fontSize: 16,
               color: Color.fromRGBO(13, 30, 56, 1),
             ),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 10),
            Column(
              children: [
                ElevatedButton(
                  onPressed: (){
                  Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding:const EdgeInsets.symmetric(horizontal: 105,vertical: 15),
                    shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                   child:const Text('Login'),),
               const SizedBox(height: 10),
                OutlinedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/register');
                    },
                    style: OutlinedButton.styleFrom(
                      padding:const EdgeInsets.symmetric(horizontal: 95,vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child:const Text('Register'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
    );
  }
}
