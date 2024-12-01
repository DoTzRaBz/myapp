import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_faq_screen.dart'; // Pastikan untuk mengimpor EditFAQScreen

class HomeStaff extends StatelessWidget {
  const HomeStaff({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the Staff Home Page!',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              _buildMenuButton(context, 'View Interactive Map', '/map'),
              _buildMenuButton(context, 'Manage POI', '/manage_poi'),
              _buildMenuButton(context, 'FAQ', null), // Ganti rute dengan null
              _buildMenuButton(context, 'System Dashboard', '/dashboard'),
              _buildMenuButton(context, 'Update Content', '/update_content'),
              _buildMenuButton(context, 'Manage Tour Packages', '/manage_tour'),
              _buildMenuButton(context, 'View Analytics', '/analytics'),
              _buildMenuButton(context, 'Generate Report', '/report'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String? route) {
    return ElevatedButton(
      onPressed: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        } else {
          // Jika rute null, arahkan ke EditFAQScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditFAQScreen(
                onUpdate: (String question, String answer) {
                  // Logika untuk memperbarui FAQ jika diperlukan
                },
              ),
            ),
          );
        }
      },
      child: Text(title),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Colors.green,
      ),
    );
  }
}