import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VaksinForm extends StatefulWidget {
  final String kandangId; // Changed to int
  final Map<String, dynamic>? vaksinToEdit;
  final VoidCallback? onSave;

  const VaksinForm({
    super.key,
    required this.kandangId,
    this.vaksinToEdit,
    this.onSave,
  });

  @override
  State<VaksinForm> createState() => _VaksinFormState();
}

class _VaksinFormState extends State<VaksinForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tanggalVaksinController = TextEditingController();
  TextEditingController kuantitasController = TextEditingController();
  TextEditingController hargaSatuanController = TextEditingController();
  String? jenisVaksinTerpilih;
  bool isLoading = false;
  String? errorMessage;
  int? userId; // Add user ID field

  // List of vaccine options
  List<String> opsiJenisVaksin = ['ND', 'IB', 'Gumboro'];

  @override
  void initState() {
    super.initState();
    // Set default date to today
    tanggalVaksinController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    // For this example, hardcode userId to 1
    // In a real app, you would get this from authentication state
    userId = 1;

    // If editing, pre-fill form fields
    if (widget.vaksinToEdit != null) {
      jenisVaksinTerpilih = widget.vaksinToEdit!['jenis_vaksin'];
      tanggalVaksinController.text = widget.vaksinToEdit!['tgl_vaksin'];
      kuantitasController.text = widget.vaksinToEdit!['kuantitas'].toString();
      hargaSatuanController.text =
          widget.vaksinToEdit!['harga_satuan'].toString();
    }
  }

  Future<void> _pilihTanggal(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          controller.text.isNotEmpty
              ? DateTime.parse(controller.text)
              : DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF82985E), // Warna utama
              onPrimary: Colors.white, // Warna teks di atas primary
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

  Future<void> _saveVaksin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
        'kandang_id': widget.kandangId,
        'jenis_vaksin': jenisVaksinTerpilih,
        'tgl_vaksin': tanggalVaksinController.text,
        'kuantitas': kuantitasController.text,
        'harga_satuan': hargaSatuanController.text,
      };

      if (kDebugMode) {
        print('Sending data: $data');
      }

      final Uri url =
          widget.vaksinToEdit != null
              ? Uri.parse(
                'https://ayamku.web.id/api/vaksins/${widget.vaksinToEdit!['id']}',
              )
              : Uri.parse('https://ayamku.web.id/api/vaksins');

      final http.Response response;

      if (widget.vaksinToEdit != null) {
        response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
      } else {
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );
      }

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (widget.onSave != null) {
          widget.onSave!();
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vaksinToEdit != null
                  ? 'Vaksin berhasil diupdate'
                  : 'Vaksin berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = 'Gagal menyimpan data: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        title: Text(
          widget.vaksinToEdit != null ? 'Edit Vaksin' : 'Tambah Vaksin',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF82985E)),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),

                      // Jenis Vaksin (menggunakan dropdown)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Jenis Vaksin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                        ),
                        value: jenisVaksinTerpilih,
                        items:
                            opsiJenisVaksin.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            jenisVaksinTerpilih = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jenis vaksin harus dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Tanggal Vaksin
                      TextFormField(
                        controller: tanggalVaksinController,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Vaksin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            onPressed:
                                () => _pilihTanggal(
                                  context,
                                  tanggalVaksinController,
                                ),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal vaksin harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Kuantitas (dosis)
                      TextFormField(
                        controller: kuantitasController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kuantitas (dosis)',
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
                          labelText: 'Harga Satuan (Rp)',
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
                      const SizedBox(height: 32.0),
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
                        onPressed: _saveVaksin,
                        child: Text(
                          widget.vaksinToEdit != null ? 'Update' : 'Simpan',
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
