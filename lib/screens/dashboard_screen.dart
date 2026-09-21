
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

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