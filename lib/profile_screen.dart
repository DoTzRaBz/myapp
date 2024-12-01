import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  final String? email;
  const ProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.email != null) {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmail(widget.email!);
      setState(() {
        _userData = user;
        // Cek apakah ada path gambar tersimpan
        if (user != null && user['profile_image'] != null) {
          _imageFile = File(user['profile_image']);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final dbHelper = DatabaseHelper();
      await dbHelper.updateProfileImage(widget.email!, pickedFile.path);

      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _userData == null
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Foto Profil
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : AssetImage('lib/assets/pp.png')
                                  as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Informasi Pengguna
                      _buildProfileInfo(
                          'Nama', _userData!['name'] ?? 'Tidak ada nama'),
                      _buildProfileInfo(
                          'Email', _userData!['email'] ?? 'Tidak ada email'),

                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                        ),
                        onPressed: _pickImage,
                        child: Text('Ubah Foto Profil'),
                      )
                    ],
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Peta',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            if (widget.email != null) {
              Navigator.pushReplacementNamed(context, '/home',
                  arguments: widget.email);
            }
          } else if (index == 2) {
            Navigator.pushNamed(context, '/map');
          }
        },
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
