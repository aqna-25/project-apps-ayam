import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'kandang.dart';

class AddKandangPage extends StatefulWidget {
  const AddKandangPage({super.key});

  @override
  State<AddKandangPage> createState() => AddKandangPageState();
}

class AddKandangPageState extends State<AddKandangPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  int? _userId;

  final _namaKandangController = TextEditingController();
  final _kapasitasKandangController = TextEditingController();
  final _alamatKandangController = TextEditingController();

  String? _jenisKandang;
  String? _tingkatKandang;
  String? _provinsi;
  String? _kotaKabupaten;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaKandangController.dispose();
    _kapasitasKandangController.dispose();
    _alamatKandangController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
      _userId = prefs.getInt('user_id');

      // If there's no user ID but there is a token, try checking login status
      if (_userId == null && _token != null) {
        _checkTokenValidity();
      }
    });
  }

  // Method to validate token and get user info if needed
  Future<void> _checkTokenValidity() async {
    try {
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (userData['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('user_id', userData['id']);
          setState(() {
            _userId = userData['id'];
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveKandangData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    // Check if user is logged in
    if (_userId == null || _token == null) {
      setState(() {
        _errorMessage =
            'User belum login atau sesi telah berakhir. Silakan login kembali.';
      });
      return;
    }

    final kandangData = {
      'user_id': _userId.toString(),
      'nama_kandang': _namaKandangController.text,
      'kapasitas_kandang': _kapasitasKandangController.text,
      'jenis_kandang': _jenisKandang,
      'tingkat_kandang': _tingkatKandang,
      'provinsi': _provinsi,
      'kota': _kotaKabupaten,
      'alamat_kandang': _alamatKandangController.text,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_kandang_data', jsonEncode(kandangData));
    await _submitKandangToAPI(kandangData);
  }

  Future<void> _submitKandangToAPI(Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://ayamku.web.id/api/kandangs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kandang_response', response.body);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kandang berhasil ditambahkan')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const KandangPage()),
          );
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage =
              'Sesi login Anda telah berakhir. Silakan login kembali.';
        });
      } else {
        try {
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage =
                errorData['message'] ??
                'Terjadi kesalahan saat menyimpan data.';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Error ${response.statusCode}: ${response.body}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan. Silakan coba lagi.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String validatorMsg,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator:
            (value) => (value == null || value.isEmpty) ? validatorMsg : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String validatorMsg,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: value,
        isExpanded: true,
        hint: Text('Pilih $label'),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? validatorMsg : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),

                  _buildTextInput(
                    controller: _namaKandangController,
                    label: 'Nama kandang',
                    validatorMsg: 'Masukkan Nama kandang',
                  ),

                  _buildTextInput(
                    controller: _kapasitasKandangController,
                    label: 'Kapasitas kandang',
                    validatorMsg: 'Masukkan Kapasitas kandang',
                    keyboardType: TextInputType.number,
                  ),

                  _buildDropdown(
                    label: 'Jenis kandang',
                    value: _jenisKandang,
                    items: ['Jenis 1', 'Jenis 2', 'Jenis 3'],
                    onChanged: (val) => setState(() => _jenisKandang = val),
                    validatorMsg: 'Pilih Jenis kandang',
                  ),

                  _buildDropdown(
                    label: 'Tingkat kandang',
                    value: _tingkatKandang,
                    items: ['Tingkat 1', 'Tingkat 2', 'Tingkat 3'],
                    onChanged: (val) => setState(() => _tingkatKandang = val),
                    validatorMsg: 'Pilih Tingkat kandang',
                  ),

                  _buildDropdown(
                    label: 'Provinsi',
                    value: _provinsi,
                    items: ['DKI Jakarta', 'Jawa Barat', 'Banyumas'],
                    onChanged: (val) => setState(() => _provinsi = val),
                    validatorMsg: 'Pilih Provinsi',
                  ),

                  _buildDropdown(
                    label: 'Kota/kabupaten',
                    value: _kotaKabupaten,
                    items: ['Jakarta', 'Bandung', 'Banyumas'],
                    onChanged: (val) => setState(() => _kotaKabupaten = val),
                    validatorMsg: 'Pilih Kota/kabupaten',
                  ),

                  _buildTextInput(
                    controller: _alamatKandangController,
                    label: 'Alamat kandang',
                    validatorMsg: 'Masukkan Alamat kandang',
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Color(0xff77875E),
                      )
                      : ElevatedButton(
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
                        onPressed: _saveKandangData,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
