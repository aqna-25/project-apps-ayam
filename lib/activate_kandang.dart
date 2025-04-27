import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'kandang.dart';

class AktivasiKandangPage extends StatefulWidget {
  final int? kandangId;

  const AktivasiKandangPage({super.key, this.kandangId});

  @override
  State<AktivasiKandangPage> createState() => AktivasiKandangPageState();
}

class AktivasiKandangPageState extends State<AktivasiKandangPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  int? _userId;

  // Controllers for text fields
  final _periodeController = TextEditingController();
  final _populasiDocController = TextEditingController();
  final _bobotAwalController = TextEditingController();
  final _hargaController = TextEditingController();

  // Selected values for dropdowns
  String? _jenisDoc;
  DateTime? _tglDoc;

  // List of DOC types
  final List<String> _jenisDocOptions = [
    'Broiler',
    'Layer',
    'Petelur',
    'Pedaging',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _periodeController.dispose();
    _populasiDocController.dispose();
    _bobotAwalController.dispose();
    _hargaController.dispose();
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
      } else {
        // Token might be invalid or expired
        _clearAuthData();
      }
    } catch (e) {
      // Handle error silently
      print('Error validating token: $e');
    }
  }

  void _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    setState(() {
      _token = null;
      _userId = null;
    });
  }

  Future<void> _saveBudidayaData() async {
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

    // Check if kandangId is provided
    if (widget.kandangId == null) {
      setState(() {
        _errorMessage =
            'ID Kandang tidak valid. Silakan pilih kandang yang benar.';
      });
      return;
    }

    // Check if tglDoc is selected
    if (_tglDoc == null) {
      setState(() {
        _errorMessage = 'Tanggal DOC harus dipilih';
      });
      return;
    }

    final budidayaData = {
      'user_id': _userId.toString(),
      'kandangs_id': widget.kandangId.toString(),
      'periode': _periodeController.text,
      'jenis_doc': _jenisDoc,
      'populasi_doc': _populasiDocController.text,
      'bobot_awal': _bobotAwalController.text,
      'harga': _hargaController.text,
      'tgl_doc': DateFormat('yyyy-MM-dd').format(_tglDoc!),
    };

    // Log the data being sent for debugging
    print('Submitting budidaya data: $budidayaData');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_budidaya_data', jsonEncode(budidayaData));
    await _submitBudidayaToAPI(budidayaData);
  }

  Future<void> _submitBudidayaToAPI(Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Debug: print request details
      print('API URL: https://ayamku.web.id/api/budidayas');
      print('Headers: Authorization: Bearer ${_token?.substring(0, 10)}...');
      print('Data being sent: $data');

      final response = await http.post(
        Uri.parse('https://ayamku.web.id/api/budidayas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);

          // Check if the response indicates successful database insertion
          if (responseData['success'] == true || responseData['id'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('budidaya_response', response.body);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kandang berhasil diaktivasi')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const KandangPage()),
              );
            }
          } else {
            setState(() {
              _errorMessage =
                  'Data tidak berhasil disimpan: ${responseData['message'] ?? 'Tidak ada detail error'}';
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Terjadi kesalahan saat memproses respons: $e';
          });
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        _clearAuthData();
        setState(() {
          _errorMessage =
              'Sesi login Anda telah berakhir. Silakan login kembali.';
        });
        // Optional: redirect to login page
      } else if (response.statusCode == 422) {
        // Validation error
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] ?? {};
          String errorMsg = 'Validasi gagal:';

          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMsg += '\n- ${value.first}';
            }
          });

          setState(() {
            _errorMessage = errorMsg;
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Error validasi: ${response.body}';
          });
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          setState(() {
            _errorMessage =
                errorData['message'] ??
                'Terjadi kesalahan saat menyimpan data (${response.statusCode}).';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Error ${response.statusCode}: ${response.body}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan jaringan: $e. Silakan coba lagi.';
      });
      print('Network error: $e');
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
    String? prefixText,
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
          prefixText: prefixText,
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

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _tglDoc ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF8AA653),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && picked != _tglDoc) {
            setState(() {
              _tglDoc = picked;
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal DOC',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            _tglDoc == null
                ? 'Pilih Tanggal DOC'
                : DateFormat('dd MMMM yyyy').format(_tglDoc!),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Aktivasi Kandang'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Display Kandang ID that's being activated
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0D8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work, color: Color(0xFF77875E)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Aktivasi Kandang.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF77875E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildTextInput(
                    controller: _periodeController,
                    label: 'Periode',
                    validatorMsg: 'Masukkan Periode',
                    keyboardType: TextInputType.number,
                  ),

                  _buildDropdown(
                    label: 'Jenis DOC',
                    value: _jenisDoc,
                    items: _jenisDocOptions,
                    onChanged: (val) => setState(() => _jenisDoc = val),
                    validatorMsg: 'Pilih Jenis DOC',
                  ),

                  _buildTextInput(
                    controller: _populasiDocController,
                    label: 'Populasi DOC',
                    validatorMsg: 'Masukkan Populasi DOC',
                    keyboardType: TextInputType.number,
                  ),

                  _buildTextInput(
                    controller: _bobotAwalController,
                    label: 'Bobot Awal (gram)',
                    validatorMsg: 'Masukkan Bobot Awal',
                    keyboardType: TextInputType.number,
                  ),

                  _buildTextInput(
                    controller: _hargaController,
                    label: 'Harga DOC (Rp)',
                    validatorMsg: 'Masukkan Harga DOC',
                    keyboardType: TextInputType.number,
                    prefixText: 'Rp ',
                  ),

                  _buildDatePicker(),

                  const SizedBox(height: 24),

                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff77875E),
                        ),
                      )
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
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
                          onPressed: _saveBudidayaData,
                          child: const Text(
                            'Aktivasi Kandang',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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
