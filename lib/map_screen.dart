// map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart';
import '../models/POI.dart';
import 'edit_poi_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OSMFlutterMap extends StatefulWidget {
  final bool isAdminOrStaff; // Tambahkan parameter ini

  const OSMFlutterMap({Key? key, required this.isAdminOrStaff})
      : super(key: key);

  @override
  State<OSMFlutterMap> createState() => _OSMFlutterMapState();
}

class _OSMFlutterMapState extends State<OSMFlutterMap> {
  List<PointOfInterest> _pois = []; // Menyimpan daftar POI

  @override
  void initState() {
    super.initState();
    _loadPOIs(); // Memuat POI saat inisialisasi
  }

  Future<void> _loadPOIs() async {
    List<PointOfInterest> pois = await DatabaseHelper().getAllPOIs();
    setState(() {
      _pois = pois; // Memperbarui daftar POI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-6.858110, 107.630884), // Koordinat pusat peta
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _pois.map((poi) {
              return Marker(
                point: LatLng(poi.latitude, poi.longitude),
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => _showPopup(context, poi),
                  child: const Icon(
                    Icons.location_pin,
                    size: 60,
                    color: Colors.red,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context, PointOfInterest poi) async {
    // Tentukan actions berdasarkan role
    List<Widget> actions = [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Tutup'),
      )
    ];

    // Tambahkan edit dan hapus hanya untuk admin/staff
    if (widget.isAdminOrStaff) {
      actions.insertAll(0, [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPOIScreen(poi: poi),
              ),
            ).then((result) {
              if (result == true) {
                _loadPOIs(); // Memuat ulang POI setelah edit
              }
            });
          },
          child: const Text('Edit'),
        ),
        TextButton(
          onPressed: () async {
            // Tampilkan konfirmasi sebelum menghapus
            bool? confirmDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Konfirmasi Hapus'),
                content: Text('Apakah Anda yakin ingin menghapus ${poi.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Hapus'),
                  ),
                ],
              ),
            );

            if (confirmDelete == true) {
              await DatabaseHelper()
                  .deletePOI(poi.id); // Hapus POI dari database
              _loadPOIs(); // Muat ulang daftar POI
              Navigator.of(context).pop();
            }
          },
          child: const Text('Hapus'),
        ),
      ]);
    }

    // Debug print untuk memastikan path gambar benar
    print('Image URL: ${poi.imageUrl}');

    showDialog(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan mengetuk di luar dialog
      builder: (context) {
        return AlertDialog(
          title: Text(poi.name),
          content: SingleChildScrollView(
            // Tambahkan scrollview
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  // Tambahkan batasan ukuran
                  constraints: BoxConstraints(
                    maxHeight: 250, // Batasi tinggi maksimum
                    maxWidth: 300, // Batasi lebar maksimum
                  ),
                  child: poi.imageUrl.startsWith('lib/assets/')
                      ? Image.asset(
                          poi.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Asset image error: $error'); // Debug print
                            return Container(
                              color: Colors.grey[300],
                              child:
                                  Center(child: Text('Gambar tidak tersedia')),
                            );
                          },
                        )
                      : Image.network(
                          poi.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Network image error: $error'); // Debug print
                            return Container(
                              color: Colors.grey[300],
                              child:
                                  Center(child: Text('Gambar tidak tersedia')),
                            );
                          },
                        ),
                ),
                SizedBox(height: 10),
                Text(poi.description),
              ],
            ),
          ),
          actions: actions,
        );
      },
    );
  }

  void _launchMapsUrl(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
