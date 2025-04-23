import 'package:flutter/material.dart';
import 'profil.dart'; // Pastikan halaman profil sudah diimpor
import 'addkandang.dart';

class KandangPage extends StatelessWidget {
  const KandangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan background image
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("Assets/kandang.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari Kandang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown[700]?.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Anda belum memiliki kandang",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8AA653),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddKandangPage()),
                        );
                      },

                      child: const Text(
                        "Buat Kandang",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                color: Colors.black,
                onPressed: () {}, // Halaman ini saat ini
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profil(),
                    ), // Pastikan ProfilPage sudah benar
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
