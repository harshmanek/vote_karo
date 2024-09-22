import 'package:flutter/material.dart';
import 'vote.dart';
import 'results_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final List<Vote> _votes = [
    Vote(option: 'BJP', icon: Icons.thumb_up),       // BJP icon
    Vote(option: 'Congress', icon: Icons.thumb_down), // Congress icon
    Vote(option: 'Aam Aadmi Party', icon: Icons.star), // Example additional option
  ];

  Set<String> _votedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadVotedUsers();
  }

  void _loadVotedUsers() async {
    // Fetch the list of voted users from your storage or backend
  }

  void _vote(int index) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to be logged in to vote.')),
      );
      return;
    }

    if (_votedUsers.contains(user.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already voted.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Vote'),
          content: Text('Are you sure you want to vote for "${_votes[index].option}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _votes[index].count++;
                  _votedUsers.add(user.uid); // Mark this user as voted
                });

                // Save the updated voted users to persistent storage or backend
              },
            ),
          ],
        );
      },
    );
  }

  void _showResults() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(votes: _votes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote Now'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Voting Instructions'),
                    content: Text('Tap on a button to vote for an option. You can only vote once.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _votes.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(
                  _votes[index].icon,
                  size: 40.0,
                  color: Colors.teal,
                ),
                title: Text(
                  _votes[index].option,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _vote(index),
                  child: Text('Vote'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showResults,
        child: Icon(Icons.bar_chart),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
