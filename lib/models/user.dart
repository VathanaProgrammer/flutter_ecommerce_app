class User {
  final int id;
  final String email;
  final String? prefix; // Mr, Miss, other
  final String firstName;
  final String? lastName;
  final String? gender; // male, female, other
  final String? profileImageUrl;
  final bool isActive;
  final DateTime? lastLogin;
  final String? username;
  final String role; // admin, staff, customer
  final String? token; // optional, if backend sends auth token

  User({
    required this.id,
    required this.email,
    this.prefix,
    required this.firstName,
    this.lastName,
    this.gender,
    this.profileImageUrl,
    required this.isActive,
    this.lastLogin,
    this.username,
    required this.role,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      prefix: json['prefix'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      profileImageUrl: json['profile_image_url'],
      isActive: json['is_active'] ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      username: json['username'],
      role: json['role'] ?? 'customer',
      token: json['token'], // optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'prefix': prefix,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
      'username': username,
      'role': role,
      'token': token,
    };
  }

  String get fullName => '$prefix ${firstName} ${lastName}';
}
