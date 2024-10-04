import 'package:flutter/material.dart';
import 'admin.dart'; // Your AdminScreen file
import 'AdminElectionPage.dart'; // Your AdminElectionPage file

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Manage Votes and Manage Elections
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Manage Votes', icon: Icon(Icons.how_to_vote)),
              Tab(text: 'Manage Elections', icon: Icon(Icons.ballot)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminScreen(), // Tab 1: Manage Votes
            AdminElectionPage(), // Tab 2: Manage Elections
          ],
        ),
      ),
    );
  }
}
