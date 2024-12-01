import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/database_helper.dart';

class EditPriceScreen extends StatefulWidget {
  @override
  _EditPriceScreenState createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends State<EditPriceScreen> {
  final _adultTicketController = TextEditingController();
  final _childTicketController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCurrentPrices();
  }

  void _loadCurrentPrices() async {
    final prices = await _dbHelper.getLatestTicketPrices();
    if (prices != null) {
      setState(() {
        _adultTicketController.text = prices['adult_price'].toStringAsFixed(0);
        _childTicketController.text = prices['child_price'].toStringAsFixed(0);
      });
    }
  }

  void _saveprices() async {
    final adultPrice = double.tryParse(_adultTicketController.text);
    final childPrice = double.tryParse(_childTicketController.text);

    if (adultPrice == null || childPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan harga yang valid')),
      );
      return;
    }

    // Simpan harga ke database
    await _dbHelper.updateTicketPrices(adultPrice, childPrice);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Harga Berhasil Diperbarui'),
        content: Text('Harga tiket telah diupdate.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Kirim sinyal bahwa harga berubah
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
    // Simpan harga (Anda bisa menambahkan logika penyimpanan ke database)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Harga Berhasil Diperbarui'),
        content: Text('Harga tiket telah diupdate.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Harga Tiket', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _adultTicketController,
              decoration: InputDecoration(
                labelText: 'Harga Tiket Dewasa',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _childTicketController,
              decoration: InputDecoration(
                labelText: 'Harga Tiket Anak',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveprices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Simpan Perubahan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}