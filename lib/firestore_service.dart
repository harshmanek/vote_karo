import 'package:cloud_firestore/cloud_firestore.dart';
import 'election.dart';

class FirestoreService {
  final CollectionReference _electionCollection =
      FirebaseFirestore.instance.collection('elections');

  // Method to vote for a candidate
  Future<void> voteForCandidate(String electionId, String candidateId) async {
    try {
      DocumentReference electionDoc = _electionCollection.doc(electionId);

      // Use a transaction to safely update the vote count
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(electionDoc);

        if (!snapshot.exists) {
          throw Exception("Election does not exist!");
        }

        // Get the list of candidates and find the candidate to update
        List<dynamic> candidates =
            (snapshot.data() as Map<String, dynamic>)['candidates'] ?? [];

        int candidateIndex = candidates.indexWhere((candidate) => candidate['id'] == candidateId);

        if (candidateIndex == -1) {
          throw Exception("Candidate not found!");
        }

        // Increment the vote count manually
        int currentVotes = candidates[candidateIndex]['voteCount'] ?? 0;
        candidates[candidateIndex]['voteCount'] = currentVotes + 1;

        // Update the candidates array in Firestore
        transaction.update(electionDoc, {
          'candidates': candidates,
        });
      });

      print('Vote recorded successfully!');
    } catch (e) {
      print('Error voting for candidate: $e');
    }
  }


  // Method to add election to Firestore
  Future<void> addElection(Election election) async {
    try {
      await _electionCollection.add({
        'name': election.name,
        'date': election
            .date, // Assuming you have a DateTime field for the election date
        'status': 'upcoming', // Default status, change as needed
        'description': election.description ?? '', // Use empty string if null
        'location': election.location ?? '', // Use empty string if null
        'candidates': [], // Default empty array for candidates
        'createdAt': FieldValue.serverTimestamp(), // Auto-generated timestamp
        'updatedAt': FieldValue.serverTimestamp(), // Auto-generated timestamp
      });
      print('Election added successfully!');
    } catch (e) {
      print('Error adding election to Firestore: $e');
    }
  }

  // Enhanced method to get all elections from Firestore with more detailed logging
  Future<List<Election>> getElections() async {
    try {
      QuerySnapshot snapshot = await _electionCollection
          .where('status', isEqualTo: 'ongoing')
          .get(); // No filter
      if (snapshot.docs.isEmpty) {
        print('No elections found.');
      } else {
        print('Fetched ${snapshot.docs.length} elections.');
      }

      return snapshot.docs.map((doc) {
        print('Fetched Election: ${doc.data()}'); // Print each fetched document
        return Election.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error getting elections from Firestore: $e');
      return [];
    }
  }

  // Method to get a specific election by its ID
  Future<Election?> getElectionById(String electionId) async {
    try {
      DocumentSnapshot doc = await _electionCollection.doc(electionId).get();
      if (doc.exists) {
        return Election.fromFirestore(doc);
      } else {
        print('Election with ID $electionId not found.');
      }
    } catch (e) {
      print('Error getting election by ID: $e');
    }
    return null;
  }
}
