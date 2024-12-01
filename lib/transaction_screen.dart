import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:myapp/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionScreen extends StatefulWidget {
  final double totalPrice;
  const TransactionScreen({Key? key, required this.totalPrice}) : super(key: key);

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String? _paymentMethod;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi Pembayaran', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue,
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentMethodSelection(),
                if (_paymentMethod != null) _buildPaymentInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Metode Pembayaran',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _paymentMethod = 'debit';
            });
          },
          child: _buildPaymentMethodCard(
            'Debit', 
            'lib/assets/card.png', 
            _paymentMethod == 'debit',
          ),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _paymentMethod = 'e-wallet';
            });
          },
          child: _buildPaymentMethodCard(
            'E-Wallet', 
            'lib/assets/e-wallet.png',
            _paymentMethod == 'e-wallet',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String title, 
    String imagePath, 
    bool isSelected,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 40, height: 40),
          SizedBox(width: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.blue : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInput() {
    return _paymentMethod == 'debit' 
      ? _buildCardPaymentInput() 
      : _buildEWalletInput();
  }

  Widget _buildCardPaymentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Kartu',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Nomor Kartu (16 digit)',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.number,
          maxLength: 16,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.datetime,
                maxLength: 5,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submitOrder,
          child: Text(
            'Submit Order Rp ${widget.totalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 12),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildEWalletInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi E-Wallet',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _phoneNumberController,
          decoration: InputDecoration(
            labelText: 'Nomor Telepon',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
            errorText: _validatePhoneNumber(_phoneNumberController.text),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {}); // Trigger rebuild untuk validasi
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _phoneNumberController.text.length >= 10 
              ? _submitOrder 
              : null, // Disable button jika nomor tidak valid
          child: Text(
            'Submit Order Rp ${widget.totalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 12),
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }
    return null;
  }

  void _submitOrder() {
    // Validasi nomor telepon untuk E-Wallet
    if (_paymentMethod == 'e-wallet') {
      final phoneValidation = _validatePhoneNumber(_phoneNumberController.text);
      if (phoneValidation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(phoneValidation)),
        );
        return;
      }
    }

    // Validasi untuk metode debit
    if (_paymentMethod == 'debit') {
      if (_cardNumberController.text.length != 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nomor kartu harus 16 digit')),
        );
        return;
      }
      if (_expiryDateController.text.length != 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Format expiry date harus MM/YY')),
        );
        return;
      }
      if (_cvvController.text.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CVV harus 3 digit')),
        );
        return;
      }
    }

    // Simpan transaksi ke database
    _saveTransaction();

    // Tampilkan AlertDialog dengan QR Code
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Pembayaran Berhasil',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              QrImageView(
                data: 'Transaksi: ${DateTime.now().toIso8601String()}',
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 20),
              Text(
                'Total Pembayaran: Rp ${widget.totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup bottom sheet
                  Navigator.of(context)
                      .pop(); // Kembali ke halaman sebelumnya
                },
                child: Text('Selesai', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _saveTransaction() async {
    final prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('userEmail');

    final dbHelper = DatabaseHelper();
    await dbHelper.insertDetailedTransaction(
      paymentMethod: _paymentMethod ?? 'Tidak Diketahui',
      amount: widget.totalPrice,
      productName: 'Tiket Perjalanan',
      userName: userEmail ?? 'Tidak Diketahui',
    );
  }
}