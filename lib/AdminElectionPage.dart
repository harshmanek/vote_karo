import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'election.dart';
import 'candidate.dart';
import 'party.dart';
// import 'package:intl/intl.dart';

class AdminElectionPage extends StatefulWidget {
  const AdminElectionPage({super.key});

  @override
  _AdminElectionPageState createState() => _AdminElectionPageState();
}

class _AdminElectionPageState extends State<AdminElectionPage> {
  final List<Election> _elections = [];
  final List<Party> _parties = [
    Party(name: 'BJP', symbol: 'BJP Symbol'),
    Party(name: 'Congress', symbol: 'Congress Symbol'),
    Party(name: 'Aam Aadmi Party', symbol: 'AAP Symbol'),
  ];

  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _candidateNameController =
      TextEditingController();
  Party? _selectedParty;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _addElection() {
    if (_electionNameController.text.isEmpty) return;

    final newElection = Election(
      id: '', // Firestore ID will be set later
      name: _electionNameController.text,
      candidates: [],
      date: DateTime.now(), // Set the date to now
      description:
          'Election for ${_electionNameController.text}', // Add a description
      location: 'Your Location', // Set default location or ask the user
      status: 'ongoing', // Set the initial status to 'ongoing'
      createdAt:
          FieldValue.serverTimestamp(), // Keep as FieldValue for Firestore
      updatedAt:
          FieldValue.serverTimestamp(), // Keep as FieldValue for Firestore
    );

    // Save to Firestore and get the generated ID
    _firestore
        .collection('elections')
        .add(newElection.toFirestore())
        .then((docRef) {
      setState(() {
        newElection.id = docRef.id; // Set the Firestore document ID
        _elections.add(newElection); // Add the election to the list
      });
    });

    // Clear inputs
    _electionNameController.clear();
  }

  void _addCandidateToElection(Election election) {
    // Show a dialog to add candidate information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Candidate to ${election.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _candidateNameController,
                decoration: const InputDecoration(labelText: 'Candidate Name'),
              ),
              DropdownButton<Party>(
                hint: const Text('Select Party'),
                value: _selectedParty,
                onChanged: (Party? party) {
                  setState(() {
                    _selectedParty = party;
                  });
                },
                items: _parties.map((Party party) {
                  return DropdownMenuItem<Party>(
                    value: party,
                    child: Text(party.name),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add Candidate'),
              onPressed: () {
                if (_candidateNameController.text.isNotEmpty &&
                    _selectedParty != null) {
                  final newCandidate = Candidate(
                    name: _candidateNameController.text,
                    party: _selectedParty!, id: '',
                  );

                  // Update Firestore to add this candidate
                  _firestore.collection('elections').doc(election.id).update({
                    'candidates':
                        FieldValue.arrayUnion([newCandidate.toFirestore()])
                  }).then((_) {
                    setState(() {
                      election
                          .addCandidate(newCandidate); // Add candidate locally
                    });
                  });

                  // Clear inputs
                  _candidateNameController.clear();
                  _selectedParty = null;
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateElectionStatus(Election election, String status) {
    _firestore.collection('elections').doc(election.id).update({
      'status': status, // Update the status of the election
      'updatedAt': FieldValue.serverTimestamp(), // Update the updated timestamp
    }).then((_) {
      setState(() {
        election.status = status; // Update the status locally
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Create Election')),
      body: Column(
        children: [
          TextField(
            controller: _electionNameController,
            decoration: const InputDecoration(labelText: 'Election Name'),
          ),
          ElevatedButton(
            onPressed: _addElection,
            child: const Text('Create Election'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _elections.length,
              itemBuilder: (context, index) {
                var election = _elections[index];
                return ListTile(
                  title: Text(election.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...election.candidates
                          .map((candidate) => Text(candidate.name))
                          .toList(),
                      Text(
                          'Status: ${election.status}'), // Show election status
                      // Text(
                      //     'Date: ${DateFormat('yyyy-MM-dd').format(electionDate) // Format as needed
                      //     }'), // Show election date
                      Text(
                          'Location: ${election.location}'), // Show election location
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Open dialog to add candidate
                          _addCandidateToElection(election);
                        },
                        child: const Text('Add Candidate'),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          _updateElectionStatus(
                              election, value); // Update election status
                        },
                        itemBuilder: (BuildContext context) {
                          return ['ongoing', 'completed'].map((String status) {
                            return PopupMenuItem<String>(
                              value: status,
                              child: Text('Mark as $status'),
                            );
                          }).toList();
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
