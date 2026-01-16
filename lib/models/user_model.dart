class UserModel {
  final String id;
  final String name;
  final String? username;
  final String email;
  final String role;
  final String? schoolId;
  final String? schoolName;

  UserModel({
    required this.id,
    required this.name,
    this.username,
    required this.email,
    required this.role,
    this.schoolId,
    this.schoolName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'User',
      username: json['username'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      schoolId: json['school_id']?.toString(),
      schoolName: json['school_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'school_id': schoolId,
      'school_name': schoolName,
    };
  }
}
