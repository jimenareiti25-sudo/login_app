
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Store Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SansSerif',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- MODELO DE USUARIO ---
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

// --- RESULTADO DE AUTENTICACIÓN ---
class AuthResult {
  final UserModel? user;
  final String? errorMessage;

  AuthResult({this.user, this.errorMessage});
}

// --- SERVICIO DE AUTENTICACIÓN ---
class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com/users';

  static Future<AuthResult> authenticateUser(String username, String password) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        List<dynamic> usersJson = jsonDecode(response.body);

        for (var userMap in usersJson) {
          String apiUser = userMap['username'] ?? '';
          String apiPass = userMap['password'] ?? '';

          bool passMatch = apiPass == password || apiPass.replaceAll('\$', '') == password;

          if (apiUser == username && passMatch) {
            return AuthResult(user: UserModel.fromJson(userMap));
          }
        }
        return AuthResult(errorMessage: 'Usuario o contraseña incorrectos.');
      } else {
        return AuthResult(errorMessage: 'Error en el servidor (${response.statusCode}). Intenta más tarde.');
      }
    } on SocketException {
      return AuthResult(errorMessage: 'Sin conexión a internet. Verifica tu red.');
    } on http.ClientException {
      return AuthResult(errorMessage: 'Sin conexión a internet. Verifica tu red.');
    } on TimeoutException {
      return AuthResult(errorMessage: 'Tiempo de espera agotado. Verifica tu red.');
    } catch (e) {
      return AuthResult(errorMessage: 'Sin conexión a internet. Verifica tu red.');
    }
  }
}

// --- PANTALLA DE LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final Color primaryColor = const Color(0xFF536DFE);
  final Color primaryLight = const Color(0xFF8C9EFF);

  Future<void> _login() async {
    final user = _userController.text.trim();
    final pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      _showSnackBar('Por favor, ingresa usuario y contraseña.', Colors.orangeAccent);
      return;
    }

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showSnackBar('Sin conexión. Por favor, verifica tu red.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    AuthResult result = await ApiService.authenticateUser(user, pass);

    setState(() => _isLoading = false);

    if (result.user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(user: result.user!),
        ),
      );
    } else if (mounted && result.errorMessage != null) {
      _showSnackBar(result.errorMessage!, Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9), Color(0xFF9FA8DA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryLight, primaryColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.favorite, color: Colors.white, size: 30),
                        SizedBox(height: 4),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email Or User Name',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _userController,
                            hintText: 'Enter your Email here',
                            icon: Icons.email_outlined,
                            obscureText: false,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passController,
                            hintText: '••••••••••••',
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.radio_button_unchecked, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text('Remember me', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                ],
                              ),
                              Text(
                                'Forgot Password?',
                                style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

// --- DASHBOARD ---
class DashboardScreen extends StatelessWidget {
  final UserModel user;

  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors;
    final Color primaryColor;

    switch (user.role) {
      case 'Administrador':
        gradientColors = const [
          Color(0xFFF3E5F5),
          Color(0xFFE1BEE7),
          Color(0xFFCE93D8),
        ];
        primaryColor = const Color(0xFFAB47BC);
        break;

      case 'Auditor':
        gradientColors = const [
          Color(0xFFE1F5FE),
          Color(0xFFB3E5FC),
          Color(0xFF81D4FA),
        ];
        primaryColor = const Color(0xFF29B6F6);
        break;

      default:
        gradientColors = const [
          Color(0xFFFCE4EC),
          Color(0xFFF8BBD0),
          Color(0xFFF48FB1),
        ];
        primaryColor = const Color(0xFFEC407A);
        break;
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Panel de ${user.role}'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.black87,
                automaticallyImplyLeading: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 25),

                      Card(
                        elevation: 6,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                user.name.toUpperCase(),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Chip(
                                label: Text(
                                  user.role,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: primaryColor,
                              ),
                              const Divider(height: 30),

                              _buildInfoTile(Icons.perm_identity, 'ID de Usuario', '${user.id}', primaryColor),
                              _buildInfoTile(Icons.account_circle_outlined, 'Username', user.username, primaryColor),
                              _buildInfoTile(Icons.email_outlined, 'Correo', user.email, primaryColor),
                              _buildInfoTile(Icons.phone_outlined, 'Teléfono', user.phone, primaryColor),
                              _buildInfoTile(Icons.location_on_outlined, 'Dirección', user.address, primaryColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE57373),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}