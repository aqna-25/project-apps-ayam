import 'package:flutter/material.dart';

class CompleteProfilePage extends StatelessWidget {
  const CompleteProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController birthDateController = TextEditingController();
    final TextEditingController provinceController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text(
              "Lengkapi profil Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text("Silahkan lengkapi data untuk melanjutkan mendaftar"),
            const SizedBox(height: 24),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No Telp'),
            ),
            TextField(
              controller: birthDateController,
              decoration: const InputDecoration(labelText: 'Tanggal Lahir'),
            ),
            TextField(
              controller: provinceController,
              decoration: const InputDecoration(labelText: 'Provinsi'),
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'Kota/Kabupaten'),
            ),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Alamat'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8EA458),
              ),
              onPressed: () {
                // Simpan ke database (misalnya Firestore)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil berhasil disimpan")),
                );
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
