import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'home_staff.dart'; // Pastikan untuk mengimpor HomeStaff
import 'profile_screen.dart';
import 'map_screen.dart';
import 'pages/chat_screen.dart';
import 'weather_screen.dart';
import 'ticket_screen.dart';
import 'transaction_screen.dart';
import 'event_screen.dart';
import 'pages/chat_screen.dart'; // Ganti dengan path yang sesuai
import 'report_screen.dart';
import 'analysis_screen.dart';
import 'add_ticket_screen.dart';
import 'edit_price_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Login & Register',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/report': (context) => ReportScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(
              email: ModalRoute.of(context)!.settings.arguments as String),
          '/home_staff': (context) =>
              HomeStaff(), // Tambahkan rute untuk HomeStaff
          '/profile': (context) => ProfileScreen(
              email: ModalRoute.of(context)!.settings.arguments as String),
          '/map': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            final email = args is String ? args : 'user';

            return OSMFlutterMap(
                isAdminOrStaff: email == 'admin' || email == 'staff');
          },
          '/chat': (context) {
            final email = ModalRoute.of(context)!.settings.arguments
                as String; // Ambil email dari argumen
            return ChatScreen(
                isAdminOrStaff:
                    email == 'admin' || email == 'staff'); // Kirim info
          },
          '/weather': (context) => WeatherScreen(),
          '/ticket': (context) => TicketScreen(),
          '/event': (context) {
            final email = ModalRoute.of(context)!.settings.arguments as String;
            return EventScreen(
                isAdminOrStaff: email == 'admin' || email == 'staff');
          },
          '/payment': (context) {
            final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>?; // Menggunakan Map
            final totalPrice =
                args?['totalPrice'] ?? 0.0; // Menggunakan null-aware operator
            return TransactionScreen(
                totalPrice: totalPrice); // Mengirim totalPrice
          },
          '/analysis': (context) => AnalysisScreen(),
        });
  }
}
