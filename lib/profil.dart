import 'package:flutter/material.dart';
import 'home.dart';
import 'kandang.dart';
import 'loginpage.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF82985E),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset('Assets/back.png', width: 20, height: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Pengaturan', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('Assets/orangmakan.jpg'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Akun'),
                _buildTile(Icons.person_outline, 'Informasi akun'),
                _buildTile(Icons.settings_outlined, 'Edit akun'),
                _buildTile(Icons.lock_outline, 'Ubah kata sandi'),
                const SizedBox(height: 16),
                _buildSectionTitle('Informasi Lainnya'),
                _buildTile(Icons.description_outlined, 'Syarat dan ketentuan'),
                _buildTile(Icons.phone_outlined, 'Hubungi Kami'),
                _buildTile(Icons.notifications_outlined, 'Notifikasi'),
                _buildTile(Icons.star_border, 'Rating'),
                _buildTile(
                  Icons.logout,
                  'Keluar',
                  color: Colors.red,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFEF6F4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.black,
                onPressed: () {
                  _navigateTo(context, const HomePage());
                },
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                color: Colors.black,
                onPressed: () {
                  _navigateTo(context, const KandangPage());
                },
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.black,
                onPressed: () {
                  // Saat ini di halaman profil, jadi tidak perlu pindah ke halaman profil lagi.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title, {
    Color color = Colors.black,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8DAA55), width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        onTap: onTap,
      ),
    );
  }
}
