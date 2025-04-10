import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'candidate.dart';
import 'election.dart'; // Import your Election, Candidate, and Party classes
import 'results_screen.dart';

class VotingScreen extends StatefulWidget {
  final Election election;

  const VotingScreen({super.key, required this.election});

  @override
  _VotingScreenState createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  Set<String> _votedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadVotedUsers();
  }

  // Check if the user has already voted by checking Firestore
  Future<void> _loadVotedUsers() async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('elections')
        .doc(widget.election.id)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      _votedUsers = Set<String>.from(data['votedUsers'] ?? []);
    }
  }

  // Update Firestore when a user votes
  Future<void> _vote(Candidate candidate) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to vote.')),
        );
      });
      return;
    }

    if (_votedUsers.contains(user.uid)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already voted.')),
        );
      });
      return;
    }

    // Confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Vote'),
          content: Text(
              'Are you sure you want to vote for ${candidate.name} from ${candidate.party.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  final DocumentSnapshot electionDoc = await FirebaseFirestore
                      .instance
                      .collection('elections')
                      .doc(widget.election.id)
                      .get();
                  final List<dynamic> candidates = electionDoc['candidates'];
                  int candidateIndex =
                      candidates.indexWhere((c) => c['id'] == candidate.id);

                  if (candidateIndex != -1) {
                    final int currentVotes =
                        candidates[candidateIndex]['voteCount'] ?? 0;

                    candidates[candidateIndex]['voteCount'] = currentVotes + 1;
                    await FirebaseFirestore.instance
                        .collection('elections')
                        .doc(widget.election.id)
                        .update({
                      'candidates': candidates,
                      'votedUsers': FieldValue.arrayUnion([user.uid]),
                    });

                    // Locally update the UI and add the user to the voted list
                    setState(() {
                      candidate.voteCount++; // Local increment
                      _votedUsers.add(user.uid); // Mark this user as voted
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'You voted for ${candidate.name} from ${candidate.party.name}!')),
                      );
                    });
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Candidate not found!')),
                      );
                    });
                  }
                  // Update the candidate's vote count in Firestore
                } catch (e) {
                  print('Error voting: $e');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('An error occurred. Please try again.')),
                    );
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showResults() {
    // Navigate to results screen and pass the election ID to fetch live data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          election: widget.election,
          electionId: widget.election.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.election.name} - Vote Now'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Voting Instructions'),
                    content: const Text(
                        'Tap on a candidate to vote for them. You can only vote once.'),
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
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.election.candidates.length,
          itemBuilder: (context, index) {
            final candidate = widget.election.candidates[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: Icon(
                  Icons
                      .person, // Customize with candidate-specific icons if needed
                  size: 40.0,
                  color: Colors.blue,
                ),
                title: Text(
                  candidate.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Party: ${candidate.party.name}'),
                trailing: ElevatedButton(
                  onPressed: () =>
                      _vote(candidate), // Pass the Candidate object
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Vote'),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showResults,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.bar_chart),
      ),
    );
  }
}
