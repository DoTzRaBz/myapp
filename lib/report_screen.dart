import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> transactions = [];
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail().then((_) {
      // Ambil data transaksi setelah mendapatkan email
      fetchTransactionsWithUsers();
    });
  }

  Future<void> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('userEmail');
    });
  }

  Future<void> fetchTransactionsWithUsers() async {
    final db = DatabaseHelper();
    List<Map<String, dynamic>> allTransactions = await db.getAllTransactions();

    // Log untuk debugging
    print('Semua Transaksi: $allTransactions');

    transactions = allTransactions.map((transaction) {
      // Pastikan mapping kolom dengan benar
      return {
        'product_name': transaction['product_name'] ?? 'Produk Tidak Diketahui',
        'user_name': transaction['user_name'] ??
            'Tidak Diketahui', // Pastikan ini sesuai
        'transaction_date':
            transaction['transaction_date'] ?? 'Tanggal Tidak Tersedia',
        'amount': transaction['amount'] ?? 0
      };
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Text('Tidak ada transaksi untuk ditampilkan.'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(transaction['product_name']),
                            subtitle: Text(
                              'User: ${transaction['user_name']}\nTanggal: ${transaction['transaction_date']}',
                            ),
                            trailing: Text('Rp ${transaction['amount']}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
