import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PakanForm extends StatefulWidget {
  final String kandangId; // Changed to String to match API requirements
  final Map<String, dynamic>?
  pakanToEdit; // Data pakan untuk diedit, null jika membuat baru

  const PakanForm({super.key, required this.kandangId, this.pakanToEdit});

  @override
  State<PakanForm> createState() => _PakanFormState();
}

class _PakanFormState extends State<PakanForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tanggalMasukController = TextEditingController();
  TextEditingController kuantitasController = TextEditingController();
  TextEditingController hargaSatuanController = TextEditingController();

  bool _isLoading = false;
  bool _isEditMode = false;
  int? _pakanId;

  // Added declaration for these variables
  String? namaPakanTerpilih;

  // User ID should be stored or retrieved from your auth system
  String? userId; // This should be set from your authentication system

  // Pastikan list tidak null dengan menginisialisasi di sini
  List<String> opsiNamaPakan = ['Pakan A', 'Pakan B', 'Pakan C'];

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
    if (widget.pakanToEdit != null) {
      _isEditMode = true;
      _pakanId = widget.pakanToEdit!['id'];
      tanggalMasukController.text = widget.pakanToEdit!['tgl_masuk'] ?? '';
      namaPakanTerpilih = widget.pakanToEdit!['produk'];
      kuantitasController.text =
          widget.pakanToEdit!['kuantitas']?.toString() ?? '';
      hargaSatuanController.text =
          widget.pakanToEdit!['harga_satuan']?.toString() ?? '';
    }
  }

  Future<void> _pilihTanggal(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF82985E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(
                  0xFF82985E,
                ), // Warna tombol OK/Cancel
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _simpanDataPakan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate user_id is available
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
      final baseUrl = 'https://ayamku.web.id/api/pakans';
      final Uri url =
          _isEditMode
              ? Uri.parse('$baseUrl/$_pakanId') // URL untuk update (PUT/PATCH)
              : Uri.parse(baseUrl); // URL untuk create (POST)

      // Siapkan data untuk dikirim sesuai format body request API
      final Map<String, dynamic> requestData = {
        'user_id': userId, // Added required user_id
        'kandang_id': widget.kandangId,
        'tgl_masuk': tanggalMasukController.text,
        'produk': namaPakanTerpilih,
        'kuantitas': kuantitasController.text,
        'harga_satuan': hargaSatuanController.text,
      };

      if (!_isEditMode) {
        // Tambahkan timestamp untuk data baru
        requestData['created_at'] = DateTime.now().toIso8601String();
      }
      requestData['updated_at'] = DateTime.now().toIso8601String();

      // Buat HTTP request
      late http.Response response;

      if (_isEditMode) {
        // Update data yang sudah ada (PUT/PATCH)
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
                  ? 'Data pakan berhasil diperbarui'
                  : 'Data pakan berhasil disimpan',
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        title: Text(
          _isEditMode ? 'Edit Data Sapronak' : 'Tambah Data Sapronak',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Padding lebih besar untuk ruang
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Nama Pakan
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Nama Pakan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                value: namaPakanTerpilih,
                items:
                    opsiNamaPakan.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    namaPakanTerpilih = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pakan harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Tanggal Masuk
              TextFormField(
                controller: tanggalMasukController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Masuk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                ),
                readOnly: true,
                onTap: () => _pilihTanggal(context, tanggalMasukController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal masuk harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Kuantitas
              TextFormField(
                controller: kuantitasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kuantitas',
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
                    return 'Kuantitas harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Harga Satuan
              TextFormField(
                controller: hargaSatuanController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Satuan',
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
                    return 'Harga satuan harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0), // Spasi lebih besar sebelum tombol
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
                onPressed: _isLoading ? null : _simpanDataPakan,
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
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
