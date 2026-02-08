class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic>? settings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.settings,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'settings': settings,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'] ?? 'student',
    settings: json['settings'],
  );
}
