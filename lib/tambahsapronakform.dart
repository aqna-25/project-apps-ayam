import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class TambahSapronakForm extends StatefulWidget {
  const TambahSapronakForm({super.key});

  @override
  State<TambahSapronakForm> createState() => _TambahSapronakFormState();
}

class _TambahSapronakFormState extends State<TambahSapronakForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tanggalMasukController = TextEditingController();
  TextEditingController tanggalVaksinController = TextEditingController();
  String? namaPakanTerpilih;
  String? jenisVaksinTerpilih;

  List<String> opsiNamaPakan = ['Pakan A', 'Pakan B', 'Pakan C'];
  List<String> opsiJenisVaksin = ['ND', 'IB', 'Gumboro'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        title: const Text(
          'Data Sapronak',
          style: TextStyle(color: Colors.white),
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
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                value: namaPakanTerpilih,
                items:
                    opsiNamaPakan.map((String value) {
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
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kuantitas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kuantitas harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Kuantitas harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Harga Satuan
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Satuan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga satuan harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga satuan harus berupa angka';
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
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.grey,
                  ),
                ),
                readOnly: true,
                onTap: () => _pilihTanggal(context, tanggalVaksinController),
              ),
              const SizedBox(height: 16.0),

              // Jenis Vaksin
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis Vaksin',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
                value: jenisVaksinTerpilih,
                items:
                    opsiJenisVaksin.map((String value) {
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
                    return 'Jenis vaksin harus diisi';
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
                onPressed: () {
                  if (kDebugMode) {
                    print('Nama Pakan: $namaPakanTerpilih');
                    print('Tanggal Masuk: ${tanggalMasukController.text}');
                    print('Kuantitas: ...');
                    print('Harga Satuan: ...');
                    print('Tanggal Vaksin: ${tanggalVaksinController.text}');
                    print('Jenis Vaksin: $jenisVaksinTerpilih');
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
