class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  final String fcmToken;
  final int totalOrders;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    this.fcmToken = '',
    this.totalOrders = 0,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      fcmToken: map['fcmToken'] ?? '',
      totalOrders: map['totalOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'isAdmin': isAdmin,
    'fcmToken': fcmToken,
    'totalOrders': totalOrders,
    'createdAt': DateTime.now().toIso8601String(),
  };
}
