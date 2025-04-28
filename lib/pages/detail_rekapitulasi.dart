import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DetailRekapitulasi extends StatefulWidget {
  final String kandangId;
  const DetailRekapitulasi({Key? key, required this.kandangId})
    : super(key: key);
  @override
  State<DetailRekapitulasi> createState() => _DetailRekapitulasiState();
}

class _DetailRekapitulasiState extends State<DetailRekapitulasi> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<String, dynamic> kandangData = {};

  // Format rupiah
  final rupiahFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    fetchKandangData();
  }

  Future<void> fetchKandangData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/kandangs/${widget.kandangId}'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            kandangData = responseData['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = 'Data tidak ditemukan';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Gagal mengambil data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  String formatRupiah(dynamic value) {
    if (value == null) return 'Rp 0';
    if (value is String) {
      try {
        value = double.parse(value);
      } catch (e) {
        return 'Rp 0';
      }
    }
    return rupiahFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage),
              ElevatedButton(
                onPressed: fetchKandangData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Ekstrak data finansial
    final finansial = kandangData['finansial'] ?? {};
    final pendapatan = finansial['pendapatan'] ?? 0;
    final pengeluaran = finansial['pengeluaran'] ?? {};
    final totalPengeluaran = pengeluaran['total'] ?? 0;
    final estimasiKeuntungan = finansial['estimasi_keuntungan'] ?? 0;

    // Detail pengeluaran
    final pakanPengeluaran = pengeluaran['pakan'] ?? 0;
    final vaksinPengeluaran = pengeluaran['vaksin'] ?? 0;

    // Data budidaya untuk DOC
    final budidaya = kandangData['budidaya'] ?? {};
    final hargaDOC = budidaya['harga'] ?? '0';
    final populasiDOC = budidaya['populasi_doc'] ?? '0';

    // Konversi ke double untuk perhitungan
    final double hargaDOCNum =
        hargaDOC is String
            ? double.tryParse(hargaDOC) ?? 0
            : hargaDOC.toDouble();
    final double populasiDOCNum =
        populasiDOC is String
            ? double.tryParse(populasiDOC) ?? 0
            : populasiDOC.toDouble();

    final docPengeluaran = hargaDOCNum * populasiDOCNum;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    estimasiKeuntungan >= 0
                        ? Colors.green[100]
                        : Colors.yellow[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Estimasi pendapatan',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(estimasiKeuntungan),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          estimasiKeuntungan >= 0
                              ? Colors.green
                              : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pengeluaran',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildRekapitulasiItem('DOC', formatRupiah(docPengeluaran)),
            _buildRekapitulasiItem('Pakan', formatRupiah(pakanPengeluaran)),
            _buildRekapitulasiItem('OVK', formatRupiah(vaksinPengeluaran)),
            const SizedBox(height: 8),
            const Divider(),
            _buildRekapitulasiItem(
              'Total pengeluaran',
              formatRupiah(totalPengeluaran),
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            const Text(
              'Penjualan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            _buildRekapitulasiItem(
              'Pendapatan per ekor',
              _calculatePendapatanPerEkor(),
            ),
            _buildRekapitulasiItem(
              'Total penjualan',
              formatRupiah(pendapatan),
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            // Tambahan informasi kandang
          ],
        ),
      ),
    );
  }

  String _calculatePendapatanPerEkor() {
    final finansial = kandangData['finansial'] ?? {};
    final pendapatan = finansial['pendapatan'] ?? 0;
    final populasi = kandangData['populasi'] ?? {};
    final populasiAwal = populasi['awal'] ?? 0;

    double pendapatanNum =
        pendapatan is String
            ? double.tryParse(pendapatan) ?? 0
            : pendapatan.toDouble();
    double populasiAwalNum =
        populasiAwal is String
            ? double.tryParse(populasiAwal) ?? 0
            : populasiAwal.toDouble();

    if (populasiAwalNum == 0) return 'Rp 0';

    final pendapatanPerEkor = pendapatanNum / populasiAwalNum;
    return formatRupiah(pendapatanPerEkor);
  }

  Widget _buildRekapitulasiItem(
    String label,
    String value, {
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: fontWeight)),
        ],
      ),
    );
  }
}
