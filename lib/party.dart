class Party {
  String name;
  String symbol;

  Party({required this.name, required this.symbol});
  // Create a factory constructor to initialize Party from Firestore (Map format)
  factory Party.fromFirestore(Map<String, dynamic> json) {
    return Party(
      name: json['name'], symbol: '#',
    );
  }
  // Create a method to convert Party to Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
