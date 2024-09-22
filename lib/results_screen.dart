import 'package:flutter/material.dart';
import 'vote.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResultsScreen extends StatelessWidget {
  final List<Vote> votes;

  ResultsScreen({required this.votes});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: Text('Voting Results'),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                userEmail,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: votes.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  votes[index].option,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Expanded(
                      child: LinearProgressIndicator(
                        value: votes[index].count / (votes.fold<int>(0, (prev, vote) => prev + vote.count) == 0 ? 1 : votes.fold<int>(0, (prev, vote) => prev + vote.count)), // To prevent division by zero
                        backgroundColor: Colors.grey[300],
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text('${votes[index].count} votes'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
