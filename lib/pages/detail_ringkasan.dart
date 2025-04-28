import 'package:flutter/material.dart';
import 'package:projectayam/services/widget_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailRingkasan extends StatefulWidget {
  final String kandangId;

  const DetailRingkasan({Key? key, required this.kandangId}) : super(key: key);

  @override
  State<DetailRingkasan> createState() => _DetailRingkasanState();
}

class _DetailRingkasanState extends State<DetailRingkasan> {
  bool _isLoading = true;
  Map<String, dynamic> _kandangData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchKandangData();
  }

  Future<void> _fetchKandangData() async {
    try {
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/kandangs/${widget.kandangId}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            _kandangData = responseData['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage =
                'Gagal memuat data: ${responseData['message'] ?? 'Terjadi kesalahan'}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    final budidaya = _kandangData['budidaya'] ?? {};
    final populasi = _kandangData['populasi'] ?? {};
    final totalPanen = _kandangData['panen']?.length ?? 0;

    // Format tanggal dari API
    final docInDate =
        budidaya['tgl_doc'] != null ? _formatDate(budidaya['tgl_doc']) : 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildInfoCard(
                      'Periode',
                      budidaya['periode'] ?? 'N/A',
                      Colors.redAccent,
                    ),
                    buildInfoCard(
                      'Umur',
                      '${_kandangData['total_days'] ?? 0} Hari',
                      Colors.lightBlueAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildInfoCard(
                      'Panen',
                      '$totalPanen Ekor',
                      Colors.greenAccent,
                    ),
                    buildInfoCard('DOC In', docInDate, Colors.orangeAccent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi ayam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jenis DOC'),
                    Text(budidaya['jenis_doc'] ?? 'N/A'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bobot awal'),
                    Text('${budidaya['bobot_awal'] ?? 'N/A'} g'),
                  ],
                ),
                const Divider(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Populasi awal'), Text('Populasi sekarang')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${populasi['awal'] ?? budidaya['populasi_doc'] ?? '0'} ekor',
                    ),
                    Text('${populasi['saat_ini'] ?? '0'} ekor'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Performa adalah akumulasi dari data harian.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return monthNames[month - 1];
  }
}
