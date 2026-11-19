class UserProfileModel {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final List<String> favorites;

  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.role = 'buyer',
    this.favorites = const [],
  });

  bool get exists => uid.isNotEmpty;

  factory UserProfileModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    return UserProfileModel(
      uid: uid ?? map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'buyer',
      favorites: (map['favorites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role,
      'favorites': favorites,
    };
  }

  Map<String, dynamic> data() => toMap();

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    String? role,
    List<String>? favorites,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      favorites: favorites ?? this.favorites,
    );
  }
}
