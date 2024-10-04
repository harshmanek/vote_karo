import 'package:cloud_firestore/cloud_firestore.dart';
import 'candidate.dart';
import 'result.dart';

class Election {
  String id; // Document ID
  String name;
 final DateTime date; // Field for the election date
 final String description; // Description of the election
 final String location; // Location of the election
 final List<Candidate> candidates;
  String status; // Status of the election
  dynamic createdAt; // Timestamp when the election was created
  dynamic updatedAt; // Timestamp when the election was last updated

  Election({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.location,
    required this.candidates,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  void addCandidate(Candidate candidate) {
    candidates.add(candidate);
  }

  Result getResults() {
    return Result(electionName: name, candidates: candidates);
  }

  // Create a factory constructor to initialize Election from Firestore
  factory Election.fromFirestore(DocumentSnapshot doc) {
    // Safely cast the document data to Map<String, dynamic>
    Map<String,dynamic> data = doc.data() as Map<String, dynamic>; // Ensure this is a map

    // Check for null or invalid data and handle it safely
    if (data == null) {
      throw Exception('Document data is null!');
    }

    // Deserialize the list of candidates, ensuring proper casting
    List<Candidate> candidates = (data['candidates'] as List<dynamic>?)
        ?.map((candidateData) {
      Map<String, dynamic> candidateMap = candidateData as Map<String, dynamic>;
      return Candidate.fromFirestore(candidateMap);
    }).toList() ?? [];

    return Election(
      id: doc.id, // Assign the document ID to the id field
      name: data['name'] as String? ?? 'No name', // Provide default if missing
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(), // Convert Timestamp, provide default if null
      description: data['description'] as String? ?? 'No description', // Provide default if missing
      location: data['location'] as String? ?? 'No location', // Provide default if missing
      candidates: candidates,
      status: data['status'] as String? ?? 'unknown', // Provide default if missing
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // Convert Timestamp if exists
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(), // Convert Timestamp if exists
    );
  }


  // Convert Election to Firestore-friendly Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': Timestamp.fromDate(date), // Firestore expects a Timestamp object
      'description': description,
      'location': location,
      'candidates': candidates.map((candidate) => candidate.toFirestore()).toList(),
      'status': status,
      'createdAt': FieldValue.serverTimestamp(), // Automatically set by Firestore
      'updatedAt': FieldValue.serverTimestamp(), // Automatically set by Firestore
    };
  }
}
