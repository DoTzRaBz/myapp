import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:myapp/database_helper.dart'; // Pastikan import database helper
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  // Variabel untuk tiket dan harga
  int _adultTickets = 0;
  int _childTickets = 0;
  double _ticketPrice = 50000; // Harga tiket dewasa
  double _childTicketPrice = 25000; // Harga tiket anak
  final TextEditingController _promoController = TextEditingController();
  double _discountPercentage = 0.0;
  String? _appliedPromoCode;

  // Variabel untuk menyimpan transaksi
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Metode untuk mengambil transaksi dari database
  Future<void> _fetchTransactions() async {
    final dbHelper = DatabaseHelper();
    try {
      final transactions = await dbHelper.getAllTransactions();

      // Tambahkan logging untuk debug
      print('Jumlah transaksi: ${transactions.length}');
      transactions.forEach((transaction) {
        print('Transaksi: $transaction');
      });

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metode increment dan decrement tiket
  void _incrementAdultTicket() {
    setState(() {
      _adultTickets++;
    });
  }

  void _decrementAdultTicket() {
    setState(() {
      if (_adultTickets > 0) _adultTickets--;
    });
  }

  void _incrementChildTicket() {
    setState(() {
      _childTickets++;
    });
  }

  void _decrementChildTicket() {
    setState(() {
      if (_childTickets > 0) _childTickets--;
    });
  }

  // Hitung total harga
  double _calculateTotal() {
    return (_adultTickets * _ticketPrice) + (_childTickets * _childTicketPrice);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green[800],
          title: Text(
            'Tiket Tahura',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Kembali ke halaman sebelumnya
            },
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  'Beli Tiket',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Tiket Saya',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Pertama: Beli Tiket
            _buildTicketPurchaseTab(),

            // Tab Kedua: Tiket Saya
            _buildMyTicketTab(),
          ],
        ),
      ),
    );
  }

  // Widget Tab Beli Tiket
  Widget _buildTicketPurchaseTab() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/screen.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTicketTypeCard(
                title: 'Tiket Dengan Pemandu',
                price: _ticketPrice,
                count: _adultTickets,
                onIncrement: _incrementAdultTicket,
                onDecrement: _decrementAdultTicket,
              ),
              SizedBox(height: 16),
              _buildTicketTypeCard(
                title: 'Tiket Masuk',
                price: _childTicketPrice,
                count: _childTickets,
                onIncrement: _incrementChildTicket,
                onDecrement: _decrementChildTicket,
              ),
              SizedBox(height: 24),
              _buildTotalSection(),
              SizedBox(height: 24),
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Tab Tiket Saya
  Widget _buildMyTicketTab() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (_transactions.isEmpty) {
      return _buildNoTicketMessage();
    }

    // Ambil transaksi terakhir (yang paling baru)
    final lastTransaction = _transactions.first;

    return Container(
      color: Colors.white,
      child: Center(
        child: _buildTicketQRCode(lastTransaction),
      ),
    );
  }

  // Widget Kartu Tipe Tiket
  Widget _buildTicketTypeCard({
    required String title,
    required double price,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rp ${price.toStringAsFixed(0)}',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.white),
                onPressed: onDecrement,
              ),
              Text(
                '$count',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.white),
                onPressed: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Total Harga
  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Harga',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Rp ${_calculateTotal().toStringAsFixed(0)}',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Pembayaran
  Widget _buildPaymentButton() {
    return ElevatedButton(
      onPressed: _adultTickets + _childTickets > 0
          ? () {
              // Simulasi pembayaran berhasil
              _saveTransaction();
              Navigator.pushNamed(context, '/payment', arguments: {
                'adultTickets': _adultTickets,
                'childTickets': _childTickets,
                'totalPrice': _calculateTotal(),
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Colors.green,
      ),
      child: Text(
        'Lanjut Pembayaran',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget QR Code untuk tiket
  Widget _buildTicketQRCode(Map<String, dynamic> transaction) {
    Map<String, dynamic> transactionData = {};

    try {
      // Coba parse product_name sebagai JSON
      transactionData = jsonDecode(transaction['product_name'] ?? '{}');
    } catch (e) {
      // Jika parsing gagal, gunakan data transaksi asli
      transactionData = {
        'payment_method': transaction['payment_method'] ?? 'Tidak Diketahui',
        'total_price': transaction['amount'] ?? 0.0,
        'transaction_date':
            transaction['transaction_date'] ?? DateTime.now().toIso8601String(),
        'product_name': transaction['product_name'] ?? 'Tiket Perjalanan',
      };
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QrImageView(
          data: jsonEncode(transactionData),
          version: QrVersions.auto,
          size: 250,
        ),
        SizedBox(height: 20),
        Text(
          'Produk: ${transactionData['product_name'] ?? 'Tiket'}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Total Bayar: Rp ${(transactionData['total_price'] ?? 0.0).toStringAsFixed(0)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        Text(
          'Metode Bayar: ${transactionData['payment_method'] ?? 'Tidak Diketahui'}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          'Tanggal: ${transactionData['transaction_date'] ?? 'Tidak diketahui'}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Pesan jika belum ada tiket
  Widget _buildNoTicketMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.confirmation_number_outlined,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Text(
          'Belum Ada Tiket',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          'Silakan beli tiket terlebih dahulu',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

void _saveTransaction() async {
  final prefs = await SharedPreferences.getInstance();
  String? userEmail = prefs.getString('userEmail');

  final dbHelper = DatabaseHelper();
  await dbHelper.insertDetailedTransaction(
    paymentMethod: 'Tiket Masuk', 
    amount: _calculateTotal(),
    productName: 'Tiket Perjalanan',
    userName: userEmail ?? 'Tidak Diketahui',
    adultTickets: _adultTickets,
    childTickets: _childTickets,
  );
}
}
