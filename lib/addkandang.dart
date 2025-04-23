import 'package:flutter/material.dart';
import 'detailkandang.dart'; // Pastikan import ini ada
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Tambah Kandang Baru', home: AddKandangPage());
  }
}

class AddKandangPage extends StatefulWidget {
  const AddKandangPage({super.key});
  @override
  AddKandangPageState createState() => AddKandangPageState();
}

class AddKandangPageState extends State<AddKandangPage> {
  final _formKey = GlobalKey<FormState>();

  String? _namaKandang;
  String? _kapasitasKandang;
  String? _jenisKandang;
  String? _tingkatKandang;
  String? _provinsi;
  String? _kotaKabupaten;
  String? _alamatKandang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Tambah Kandang Baru'),
        backgroundColor: const Color(0xFF8AA653),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(
                    'Nama kandang',
                    (value) => _namaKandang = value,
                  ),
                  _buildTextField(
                    'Kapasitas kandang',
                    (value) => _kapasitasKandang = value,
                    keyboardType: TextInputType.number,
                  ),
                  _buildDropdown('Jenis kandang', [
                    'Jenis 1',
                    'Jenis 2',
                    'Jenis 3',
                  ], (value) => _jenisKandang = value),
                  _buildDropdown('Tingkat kandang', [
                    'Tingkat 1',
                    'Tingkat 2',
                    'Tingkat 3',
                  ], (value) => _tingkatKandang = value),
                  _buildDropdown('Provinsi', [
                    'Provinsi 1',
                    'Provinsi 2',
                    'Provinsi 3',
                  ], (value) => _provinsi = value),
                  _buildDropdown('Kota/kabupaten', [
                    'Kota/Kabupaten 1',
                    'Kota/Kabupaten 2',
                    'Kota/Kabupaten 3',
                  ], (value) => _kotaKabupaten = value),
                  _buildTextField(
                    'Alamat kandang',
                    (value) => _alamatKandang = value,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff77875E),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (kDebugMode) {
                        _formKey.currentState!.save();
                        print('Nama Kandang: $_namaKandang');
                        print('Kapasitas Kandang: $_kapasitasKandang');
                        print('Jenis Kandang: $_jenisKandang');
                        print('Tingkat Kandang: $_tingkatKandang');
                        print('Provinsi: $_provinsi');
                        print('Kota/Kabupaten: $_kotaKabupaten');
                        print('Alamat Kandang: $_alamatKandang');

                        // Navigasi ke DetailKandangPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailKandangPage(),
                          ),
                        );
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String?) onSaved, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'Masukkan $label' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Pilih $label' : null,
      ),
    );
  }
}
