import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'candidate.dart';
import 'election.dart';  // Assuming this contains the Election and Candidate classes

class ResultsScreen extends StatelessWidget {
  final String electionId; // Pass the election ID to retrieve data

  const ResultsScreen({super.key, required this.electionId, required Election election});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting Results'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                userEmail,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('elections')
            .doc(electionId) // Listening to updates for this election
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Election not found.'));
          }

          // Retrieve election data from the snapshot
          final electionData = snapshot.data!.data() as Map<String, dynamic>;

          // Deserialize the list of candidates
          final List<dynamic> candidateList = electionData['candidates'] ?? [];
          final List<Candidate> candidates = candidateList
              .map((data) => Candidate.fromFirestore(data))
              .toList();

          // Calculate the total number of votes
          int totalVotes = candidates.fold<int>(
            0,
                (sum, candidate) => sum + candidate.voteCount,
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                final double votePercentage = totalVotes == 0
                    ? 0
                    : (candidate.voteCount / totalVotes);

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      candidate.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Party: ${candidate.party.name}'),
                        const SizedBox(height: 8.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: LinearProgressIndicator(
                                value: votePercentage,
                                backgroundColor: Colors.grey[300],
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                                '${candidate.voteCount} votes (${(votePercentage * 100).toStringAsFixed(2)}%)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
