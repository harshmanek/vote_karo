import 'package:uuid/uuid.dart';

import 'party.dart';

class Candidate {
  String id;
  final String name;
  final Party party;
  int voteCount;

  static const Uuid uuid = Uuid();

  Candidate({
    String? id,
    required this.name,
    required this.party,
    this.voteCount = 0,
  }) : id = id ?? uuid.v4();

  // Create a factory constructor to initialize Candidate from Firestore
  factory Candidate.fromFirestore(Map<String, dynamic> json) {
    // Ensure the json map has the correct keys and handle null values
    return Candidate(
      id: json['id'] as String? ?? '', // Default to empty string if id is null
      name: json['name'] as String? ?? 'No name', // Default to 'No name' if missing
      party: json['party'] != null
          ? Party.fromFirestore(json['party'] as Map<String, dynamic>)
          : Party(name: 'Unknown Party', symbol: 'Unknown Symbol'), // Handle null party safely
      voteCount: json['voteCount'] as int? ?? 0, // Default to 0 if null
    );
  }

  // Convert the Candidate object to a Firestore-friendly Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'party': party.toFirestore(), // Serialize Party
      'voteCount': voteCount,
    };
  }
}
