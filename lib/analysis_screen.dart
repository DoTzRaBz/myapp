import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  List<Map<String, dynamic>> _analysisData = [];
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalysisData();
  }

  Future<void> _fetchAnalysisData() async {
    setState(() {
      _isLoading = true;
    });

    final dbHelper = DatabaseHelper();
    
    try {
      final transactions = await dbHelper.getTransactionsByDateRange(
        _startDate, 
        _endDate
      );

      _processAnalysisData(transactions);
    } catch (e) {
      print('Error fetching analysis data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processAnalysisData(List<Map<String, dynamic>> transactions) {
    Map<String, double> dailyRevenue = {};
    
    for (var transaction in transactions) {
      String date = transaction['transaction_date'].split('T')[0];
      double amount = transaction['amount'] ?? 0.0;
      
      dailyRevenue[date] = (dailyRevenue[date] ?? 0) + amount;
    }

    _analysisData = dailyRevenue.entries
        .map((entry) => {
              'date': entry.key,
              'revenue': entry.value,
            })
        .toList();
  }

  void _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchAnalysisData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analisis Penggunaan Sistem'),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildAnalysisContent(),
    );
  }

  Widget _buildAnalysisContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSection(),
            SizedBox(height: 20),
            _buildRevenueChart(),
            SizedBox(height: 20),
            _buildSummaryStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Periode:',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      Text(
        '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      Center(
        child: ElevatedButton(
          onPressed: _showDateRangePicker,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(
            'Ubah Periode',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildRevenueChart() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        title: ChartTitle(text: 'Pendapatan Harian'),
        series: <CartesianSeries<Map<String, dynamic>, String>>[
          LineSeries<Map<String, dynamic>, String>(
            dataSource: _analysisData,
            xValueMapper: (data, _) => data['date'],
            yValueMapper: (data, _) => data['revenue'],
            name: 'Pendapatan',
            dataLabelSettings: DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistics() {
    double totalRevenue = _analysisData.fold(
      0, 
      (sum, data) => sum + (data['revenue'] ?? 0)
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Statistik',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildStatItem('Total Pendapatan', 'Rp ${totalRevenue.toStringAsFixed(2)}'),
            _buildStatItem('Jumlah Transaksi', _analysisData.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 16),
          ),
        ],
      ),
    );
  }
}