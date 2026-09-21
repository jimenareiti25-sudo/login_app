
class UserModel {
  final int id;
  final String email;
  final String username;
  final String name;
  final String phone;
  final String address;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int userId = json['id'] as int;

    String assignedRole;
    if (userId == 1 || userId == 2) {
      assignedRole = 'Administrador';
    } else if (userId == 3) {
      assignedRole = 'Auditor';
    } else {
      assignedRole = 'Cliente';
    }

    String firstName = json['name'] != null ? json['name']['firstname'] ?? '' : '';
    String lastName = json['name'] != null ? json['name']['lastname'] ?? '' : '';
    String fullName = '$firstName $lastName'.trim();
    if (fullName.isEmpty) fullName = json['username'] ?? 'Usuario';

    String street = json['address'] != null ? json['address']['street'] ?? '' : '';
    String number = json['address'] != null ? json['address']['number']?.toString() ?? '' : '';
    String city = json['address'] != null ? json['address']['city'] ?? '' : '';
    String fullAddress = '$street $number, $city'.trim();

    return UserModel(
      id: userId,
      email: json['email'] ?? 'No especificado',
      username: json['username'] ?? '',
      name: fullName,
      phone: json['phone'] ?? 'No disponible',
      address: fullAddress.isNotEmpty ? fullAddress : 'No especificada',
      role: assignedRole,
    );
  }
}

class AuthResult {
  final UserModel? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}