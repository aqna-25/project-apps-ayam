import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class TambahPanenForm extends StatefulWidget {
  const TambahPanenForm({super.key});

  @override
  State<TambahPanenForm> createState() => _TambahPanenFormState();
}

class _TambahPanenFormState extends State<TambahPanenForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController tanggalPanenController = TextEditingController();
  TextEditingController pembeliController = TextEditingController();
  TextEditingController jumlahPanenController = TextEditingController();
  TextEditingController tonaseController = TextEditingController();
  TextEditingController bodyWeightController = TextEditingController();
  TextEditingController hargaPerKgController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
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
                foregroundColor: const Color(0xFF82985E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        tanggalPanenController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        title: const Text(
          'Tambah data panen',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Tanggal panen
              TextFormField(
                controller: tanggalPanenController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal panen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal panen harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Pembeli
              TextFormField(
                controller: pembeliController,
                decoration: InputDecoration(
                  labelText: 'Pembeli',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Jumlah panen
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: jumlahPanenController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah panen',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Ekor'),
                ],
              ),
              const SizedBox(height: 16.0),

              // Tonase dan Body weight
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: tonaseController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Tonase',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0',
                        suffixText: 'kg',
                        suffixStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: bodyWeightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Body weight',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '0',
                        suffixText: 'kg',
                        suffixStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Harga per kg
              TextFormField(
                controller: hargaPerKgController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga per kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: 'Rp ',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Informasi tambahan
              // Spasi lebih besar sebelum tombol
              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF82985E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (kDebugMode) {
                      print('Tanggal Panen: ${tanggalPanenController.text}');
                      print('Pembeli: ${pembeliController.text}');
                      print('Jumlah Panen: ${jumlahPanenController.text}');
                      print('Tonase: ${tonaseController.text}');
                      print('Body Weight: ${bodyWeightController.text}');
                      print('Harga per Kg: ${hargaPerKgController.text}');
                      Navigator.pop(context);
                    }
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
