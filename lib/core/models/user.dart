class User {
  final int id;
  final String username;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? pictureUrl;
  final String? authority;
  final String? type;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.phoneNumber,
    this.pictureUrl,
    this.authority,
    this.type,
  });

  // Convenience getters
  String get displayName => name ?? username;
  bool get isDriver => authority == 'DRIVER' || type == 'DRIVER';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      pictureUrl: json['pictureUrl'],
      authority: json['authority'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'pictureUrl': pictureUrl,
      'authority': authority,
      'type': type,
    };
  }

  // Equality operators for Provider comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email}';
  }
}
