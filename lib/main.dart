import 'package:flutter/material.dart';
import 'package:projectayam/home.dart';
import 'loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isUserLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginSession();
  }

  Future<void> _checkLoginSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cek apakah user login
    bool isLogin = prefs.getBool('isLogin') ?? false;

    if (isLogin) {
      // Ambil waktu login
      int? loginTimestamp = prefs.getInt('loginTimestamp');

      if (loginTimestamp != null) {
        // Hitung selisih waktu saat ini dengan waktu login (dalam milisecond)
        DateTime loginTime = DateTime.fromMillisecondsSinceEpoch(
          loginTimestamp,
        );
        DateTime currentTime = DateTime.now();
        Duration difference = currentTime.difference(loginTime);

        // Cek apakah session masih berlaku (7 hari = 7 * 24 * 60 * 60 * 1000 milisecond)
        // 7 hari dalam detik = 604800 detik
        if (difference.inSeconds > 604800) {
          // Session habis, logout user
          await prefs.setBool('isLogin', false);
          await prefs.remove('loginTimestamp');
          isLogin = false;
        }
      } else {
        // Jika tidak ada timestamp, set waktu login sekarang
        await prefs.setInt(
          'loginTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }

    setState(() {
      isUserLoggedIn = isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Ayam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          isUserLoggedIn == null
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : isUserLoggedIn!
              ? const HomePage()
              : const LoginPage(),
    );
  }
}
