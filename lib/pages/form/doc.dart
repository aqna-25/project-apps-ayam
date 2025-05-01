import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DocForm extends StatefulWidget {
  final String kandangId;
  final Map<String, dynamic>? docToEdit;
  final bool
  hasExistingData; // Tambahkan parameter baru untuk menandakan data sudah ada

  const DocForm({
    super.key,
    required this.kandangId,
    this.docToEdit,
    this.hasExistingData = false, // Default false jika tidak diisi
  });

  @override
  State<DocForm> createState() => _DocFormState();
}

class _DocFormState extends State<DocForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController bobotAwalController = TextEditingController();
  TextEditingController populasiAwalController = TextEditingController();
  TextEditingController kematianController = TextEditingController();
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _docId;

  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _getUserIdFromSharedPreferences();
  }

  Future<void> _getUserIdFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final storedUserId = prefs.getInt('user_id');

      setState(() {
        userId = storedUserId?.toString();
      });

      if (userId == null || userId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesi login Anda telah berakhir. Silakan login kembali.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pengguna: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _initializeData() {
    if (widget.docToEdit != null) {
      _isEditMode = true;
      _docId = widget.docToEdit!['id'];
      bobotAwalController.text =
          widget.docToEdit!['bobot_Awal']?.toString() ?? '';
      populasiAwalController.text =
          widget.docToEdit!['populasi_awal']?.toString() ?? '';
      kematianController.text = widget.docToEdit!['kematian']?.toString() ?? '';
    }
  }

  Future<void> _simpanDataDoc() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi user_id tersedia
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID tidak tersedia, silakan login ulang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = 'https://ayamku.web.id/api/docs';
      final Uri url =
          _isEditMode ? Uri.parse('$baseUrl/$_docId') : Uri.parse(baseUrl);

      final Map<String, dynamic> requestData = {
        'user_id': userId,
        'kandang_id': widget.kandangId,
        'bobot_Awal': bobotAwalController.text,
        'populasi_awal': populasiAwalController.text,
        'kematian': kematianController.text,
      };

      if (!_isEditMode) {
        // Tambahkan timestamp untuk data baru
        requestData['created_at'] = DateTime.now().toIso8601String();
      }
      requestData['updated_at'] = DateTime.now().toIso8601String();

      // Buat HTTP request
      late http.Response response;
      if (_isEditMode) {
        // Update data yang sudah ada (PUT)
        response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // Tambahkan header autentikasi jika diperlukan
            // 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestData),
        );
      } else {
        // Buat data baru (POST)
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // Tambahkan header autentikasi jika diperlukan
            // 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(requestData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Data DOC berhasil diperbarui'
                  : 'Data DOC berhasil disimpan',
            ),
            backgroundColor: const Color(0xFF82985E),
          ),
        );
        Navigator.pop(
          context,
          true,
        ); // Kembalikan true untuk refresh data di halaman sebelumnya
      } else {
        // Gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika ada data yang sudah ada dan kita tidak dalam mode edit, tampilkan pesan
    if (widget.hasExistingData && !_isEditMode) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF82985E),
          title: const Text('Data DOC', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 1,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 80,
                color: Color(0xFF82985E),
              ),
              const SizedBox(height: 16),
              const Text(
                'Data DOC sudah ada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Anda hanya dapat mengedit data DOC yang sudah ada. Silakan kembali ke halaman sebelumnya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF82985E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilkan form seperti biasa jika tidak ada data atau sedang dalam mode edit
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        title: Text(
          _isEditMode ? 'Edit Data DOC' : 'Tambah Data DOC',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1, // Sedikit shadow untuk memisahkan appbar
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF82985E)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(
                  20.0,
                ), // Padding lebih besar untuk ruang
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Bobot Awal
                      TextFormField(
                        controller: bobotAwalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Bobot Awal (kg)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Bobot awal harus diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Bobot awal harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Populasi Awal
                      TextFormField(
                        controller: populasiAwalController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Populasi Awal',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Populasi awal harus diisi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Populasi awal harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Kematian
                      TextFormField(
                        controller: kematianController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kematian',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah kematian harus diisi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Jumlah kematian harus berupa angka';
                          }
                          final populasi =
                              int.tryParse(populasiAwalController.text) ?? 0;
                          final kematian = int.tryParse(value) ?? 0;
                          if (kematian > populasi) {
                            return 'Kematian tidak boleh lebih besar dari populasi awal';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 32.0,
                      ), // Spasi lebih besar sebelum tombol
                      // Tombol Simpan
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF82985E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2, // Sedikit shadow pada tombol
                        ),
                        onPressed: _isLoading ? null : _simpanDataDoc,
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _isEditMode ? 'Perbarui' : 'Simpan',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
