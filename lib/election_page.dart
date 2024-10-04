import 'package:flutter/material.dart';
import 'firestore_service.dart'; // Import the Firestore service to fetch data
import 'election.dart'; // Import Election model
import 'candidates_page.dart'; // Import the CandidatesPage

class ElectionsPage extends StatefulWidget {
  const ElectionsPage({Key? key, required List<Election> elections})
      : super(key: key);

  @override
  _ElectionsPageState createState() => _ElectionsPageState();
}

class _ElectionsPageState extends State<ElectionsPage> {
  final FirestoreService _firestoreService =
      FirestoreService(); // Firestore service to fetch elections
  List<Election> _elections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElections(); // Fetch elections when the page loads
  }

  // Method to load elections from Firestore
  Future<void> _loadElections() async {
    try {
      List<Election> fetchedElections = await _firestoreService.getElections();

      // Check if any elections are fetched
      if (fetchedElections.isEmpty) {
        print('No elections found.');
      }

      setState(() {
        _elections = fetchedElections;
        isLoading = false;
      });

      // Debugging print to check the fetched elections
      print('Loaded Elections: ${_elections.length}');
      for (var election in _elections) {
        print('Election: ${election.name}, ID: ${election.id}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading elections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Elections'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : _elections.isNotEmpty
              ? ListView.builder(
                  itemCount: _elections.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(
                          _elections[index].name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to the CandidatesPage with the selected election
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CandidatesPage(
                                electionId: _elections[index]
                                    .id, // Pass the election ID to fetch candidates
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                      'No ongoing elections available.'), // Display if no elections are found
                ),
    );
  }
}
