import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Data cuaca
  double temperature = 0.0;
  double windSpeed = 0.0;
  int humidity = 0;
  String weatherCondition = 'Kondisi_Tidak_Diketahui';
  List<dynamic> forecastData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    // Koordinat Tahura Bandung
    final latitude = -6.8441;
    final longitude = 107.6381;

    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weather_code,temperature_2m_max,temperature_2m_min&current=temperature_2m,relative_humidity_2m,wind_speed_10m&hourly=weather_code&timezone=Asia%2FJakarta&forecast_days=4');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          temperature = data['current']['temperature_2m'];
          windSpeed = data['current']['wind_speed_10m'];
          humidity = data['current']['relative_humidity_2m'];

          // Mapping kode cuaca
          weatherCondition = _mapWeatherCode(data['hourly']['weather_code'][0]);

          // Forecast data
          forecastData = List.generate(4, (index) {
            return {
              'date': DateTime.now().add(Duration(days: index + 1)),
              'weather_code': data['daily']['weather_code'][index],
              'max_temp': data['daily']['temperature_2m_max'][index],
              'min_temp': data['daily']['temperature_2m_min'][index]
            };
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mapping kode cuaca
  String _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
      case 2:
      case 3:
        return 'Sebagian_Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      default:
        return 'Kondisi_Tidak_Diketahui';
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
          'Cuaca Tahura Bandung',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/assets/screen.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Kondisi Cuaca Saat Ini
                      _buildCurrentWeatherCard(),

                      // Prakiraan Cuaca 4 Hari
                      _buildForecastSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Gambar cuaca
          Image.asset(
            'lib/assets/${weatherCondition}.png',
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.cloud, color: Colors.white, size: 100);
            },
          ),
          SizedBox(height: 10),
          Text(
            weatherCondition.replaceAll('_', ' '),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherDetailItem(
                icon: Icons.thermostat,
                value: '${temperature.toStringAsFixed(1)}°C',
                label: 'Temperatur',
              ),
              _buildWeatherDetailItem(
                icon: Icons.water_drop,
                value: '$humidity%',
                label: 'Kelembapan',
              ),
              _buildWeatherDetailItem(
                icon: Icons.air,
                value: '${windSpeed.toStringAsFixed(1)} km/h',
                label: 'Kecepatan Angin',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        Text(
          value,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Prakiraan 4 Hari Kedepan',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...forecastData.map((forecast) {
            String forecastCondition =
                _mapWeatherCode(forecast['weather_code']);
            return _buildForecastItem(
              date: forecast['date'],
              condition: forecastCondition,
              maxTemp: forecast['max_temp'].toString(),
              minTemp: forecast['min_temp'].toString(),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildForecastItem({
    required DateTime date,
    required String condition,
    required String maxTemp,
    required String minTemp,
  }) {
    return ListTile(
      leading: Image.asset(
        'lib/assets/${condition}.png',
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.cloud, color: Colors.white, size: 50);
        },
      ),
      title: Text(
        DateFormat('EEEE, d MMMM').format(date),
        style: GoogleFonts.poppins(color: Colors.white),
      ),
      subtitle: Text(
        'Max: $maxTemp°C, Min: $minTemp°C',
        style: GoogleFonts.roboto(color: Colors.white70),
      ),
    );
  }
}
