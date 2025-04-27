import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'kandang.dart';
import 'loginpage.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  // Fungsi logout yang menghapus session
  Future<void> _logout(BuildContext context) async {
    // Tampilkan indikator loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF82985E)),
          ),
        );
      },
    );

    try {
      // Dapatkan instance SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Hapus status login
      await prefs.setBool('isLogin', false);

      // Hapus timestamp login
      await prefs.remove('loginTimestamp');

      // Opsional: Hapus data user lainnya jika ada
      // await prefs.remove('userEmail');
      // await prefs.remove('userName');

      // Tutup dialog loading
      Navigator.pop(context);

      // Arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      // Tutup dialog loading
      Navigator.pop(context);

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat logout: ${e.toString()}'),
        ),
      );
    }
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
