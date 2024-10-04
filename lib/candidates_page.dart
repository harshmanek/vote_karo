import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Ensure FirestoreService is imported
import 'election.dart'; // Ensure Election and related models are imported
import 'initial_page.dart';
import 'vote.dart'; // Ensure VotingScreen is imported

class CandidatesPage extends StatefulWidget {
  final String electionId; // Accept the Election ID from Firestore

  CandidatesPage({Key? key, required this.electionId}) : super(key: key);

  @override
  _CandidatesPageState createState() => _CandidatesPageState();
}

class _CandidatesPageState extends State<CandidatesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  Election? election;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElectionData();
  }

  // Method to load election data from Firestore
  Future<void> _loadElectionData() async {
    try {
      // Fetch the election by its Firestore ID
      Election? fetchedElection = await _firestoreService.getElectionById(widget.electionId);
      setState(() {
        election = fetchedElection;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading election: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(election?.name ?? 'Loading...'), // Show election name or "Loading"
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : election != null && election!.candidates.isNotEmpty
          ? ListView.builder(
        itemCount: election!.candidates.length,
        itemBuilder: (context, index) {
          final candidate = election!.candidates[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                candidate.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Party: ${candidate.party.name}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Create a new Election object (or modify as needed)
                final selectedElection = Election(
                  id: election!.id, // Use the actual election ID
                  name: election!.name,
                  date: election!.date, // Add date from the election
                  description: election!.description, // Add description
                  location: election!.location, // Add location
                  candidates: [candidate], // Pass only the selected candidate
                  status: election!.status, // Maintain status
                  createdAt: election!.createdAt, // Pass createdAt
                  updatedAt: election!.updatedAt, // Pass updatedAt
                );

                // Navigate to the VotingScreen with the Election object
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VotingScreen(
                      election: selectedElection,
                    ),
                  ),
                );
              },
            ),
          );
        },
      )
          : Center(
        child: const Text('No candidates available for this election.'), // Handle no candidates
      ),
    );
  }
}
