import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'pages/chat_screen.dart';
import 'report_screen.dart';
import 'package:myapp/database_helper.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  const HomeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Memanggil fungsi untuk mendapatkan peran pengguna
  }

  Future<void> _getUserRole() async {
  String? role = await DatabaseHelper().getUserRole(widget.email);
  setState(() {
    userRole = role;
    // Tambahkan kondisi untuk CS
    if (userRole == 'cs') {
      // Atur tampilan atau akses khusus untuk CS
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tahura Explorer',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Container(
        width: double.infinity, // Tambahkan ini
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Tahura
                _buildTahuraCarousel(),

                // Greeting Section
                _buildGreetingSection(),

                // Quick Access Menu
                _buildQuickAccessMenu(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        tooltip: 'Chat AI',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                isAdminOrStaff: widget.email == 'admin' ||
                    widget.email == 'staff', // Kirim info
              ),
            ),
          );
        },
        child: Icon(Icons.chat, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTahuraCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 250,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
      ),
      items: [1, 2, 3, 4, 5, 6, 7, 8].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage('lib/assets/tahura$i.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildGreetingSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang di Tahura',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Jelajahi keindahan alam dan keanekaragaman hayati',
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAccessButton(
              icon: Icons.cloud,
              label: 'Cuaca',
              onTap: () => Navigator.pushNamed(context, '/weather'),
            ),
            SizedBox(width: 16),

            // Hanya tampilkan ikon Analisis untuk admin/staff
            if (userRole == 'admin' || userRole == 'staff' || userRole == 'cs') ...[
            _buildQuickAccessButton(
              icon: Icons.chat,
              label: 'FAQ',
              onTap: () => Navigator.pushNamed(
                context, 
                '/chat', 
                arguments: widget.email
              ),
            ),
          ],


            _buildQuickAccessButton(
              icon: Icons.confirmation_number_outlined,
              label: 'Tiket',
              onTap: () => Navigator.pushNamed(context, '/ticket'),
            ),
            SizedBox(width: 16),
            _buildQuickAccessButton(
              icon: Icons.calendar_month,
              label: 'Event',
              onTap: () => Navigator.pushNamed(context, '/event',
                  arguments:
                      userRole // Pastikan userRole sudah didefinisikan sebelumnya
                  ),
            ),

            // Laporan hanya untuk admin/staff
            if (userRole == 'admin' || userRole == 'staff') ...[
              SizedBox(width: 16),
              _buildQuickAccessButton(
                icon: Icons.report,
                label: 'Laporan',
                onTap: () => Navigator.pushNamed(context, '/report'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      currentIndex: 1,
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
        if (index == 0) {
          Navigator.pushNamed(context, '/profile', arguments: widget.email);
        } else if (index == 2) {
          Navigator.pushNamed(context, '/map',
              arguments: userRole == 'admin' || userRole == 'staff'
                  ? 'admin'
                  : widget.email);
        }
      },
    );
  }
}
