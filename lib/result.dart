// import 'candidate.dart';
import 'candidate.dart';

class Result {
  String electionName;
  Map<Candidate, int> candidateVotes = {};

  Result({required this.electionName, required List<Candidate> candidates}) {
    for (var candidate in candidates) {
      candidateVotes[candidate] = 0; // Initialize with 0 votes
    }
  }

  void castVote(Candidate candidate) {
    candidateVotes[candidate] = (candidateVotes[candidate] ?? 0) + 1;
  }

  void showResults() {
    candidateVotes.forEach((candidate, votes) {
      print(
        '${candidate.name ?? 'Unknown Candidate'} '
            '(${candidate.party.name ??
            'Unknown Party'}) received $votes votes.',
      );
    });
  }
}
