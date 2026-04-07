class UserModel {
  final String uid;
  final String name;
  final String email;
  final double accountBalance;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.accountBalance = 0.0,
    required this.createdAt,
  });

  // Convert UserModel to a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'accountBalance': accountBalance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      accountBalance: (map['accountBalance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    double? accountBalance,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      accountBalance: accountBalance ?? this.accountBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
