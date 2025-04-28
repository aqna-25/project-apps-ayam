import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectayam/pages/form/doc.dart';

class DetailDoc extends StatefulWidget {
  final String kandangId;

  const DetailDoc({Key? key, required this.kandangId}) : super(key: key);

  @override
  State<DetailDoc> createState() => _DetailDocState();
}

class _DetailDocState extends State<DetailDoc> {
  List<Map<String, dynamic>> docList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDocData();
  }

  Future<void> fetchDocData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/kandangs/${widget.kandangId}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(
          'Raw API Response: $responseData',
        ); // Log respons mentah untuk debug

        // Cek struktur data respons
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final data = responseData['data'];

          // Cek apakah data DOC ada dan dalam format yang tepat
          if (data is Map<String, dynamic> && data.containsKey('doc')) {
            // Periksa tipe data 'doc'
            final docData = data['doc'];

            if (docData is List) {
              // Respons berupa array/list seperti yang diharapkan
              docList =
                  docData.map<Map<String, dynamic>>((item) {
                    return {
                      'id': item['id']?.toString() ?? '',
                      'bobot_awal': item['bobot_awal']?.toString() ?? '0',
                      'populasi_awal': item['populasi_awal']?.toString() ?? '0',
                      'kematian': item['kematian']?.toString() ?? '0',
                      'populasi_akhir': _calculateFinalPopulation(
                        item['populasi_awal']?.toString() ?? '0',
                        item['kematian']?.toString() ?? '0',
                      ),
                      'raw_data': item,
                    };
                  }).toList();
            } else if (docData is Map<String, dynamic>) {
              // Respons berupa objek tunggal, bukan array
              // Konversi objek tunggal ke dalam array dengan satu item
              docList = [
                {
                  'id': docData['id']?.toString() ?? '',
                  'bobot_awal': docData['bobot_awal']?.toString() ?? '0',
                  'populasi_awal': docData['populasi_awal']?.toString() ?? '0',
                  'kematian': docData['kematian']?.toString() ?? '0',
                  'populasi_akhir': _calculateFinalPopulation(
                    docData['populasi_awal']?.toString() ?? '0',
                    docData['kematian']?.toString() ?? '0',
                  ),
                  'raw_data': docData,
                },
              ];
              print(
                'DOC data is a single object, converted to list with one item',
              );
            } else {
              // Data kosong atau format tidak dikenali
              docList = [];
              print('DOC data is empty or in unrecognized format: $docData');
            }
          } else {
            docList = [];
            print(
              'Tidak ada data DOC dalam respons API atau format tidak sesuai',
            );
          }
        } else {
          setState(() {
            errorMessage = 'Format respons API tidak sesuai';
            isLoading = false;
          });
          return;
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print('API Error Status Code: ${response.statusCode}');
        setState(() {
          errorMessage = 'Gagal memuat data. Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Terjadi pengecualian: $e');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  // Calculate final population (populasi awal - kematian)
  String _calculateFinalPopulation(String populasiAwal, String kematian) {
    try {
      int populasi = int.parse(populasiAwal);
      int mati = int.parse(kematian);
      return (populasi - mati).toString();
    } catch (e) {
      return '0';
    }
  }

  // Delete DOC data
  Future<void> _deleteItem(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://ayamku.web.id/api/docs/$id'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data DOC berhasil dihapus')),
        );
        fetchDocData(); // Refresh the data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus data DOC')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF82985E)),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchDocData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF82985E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (docList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.baby_changing_station,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada data DOC tersimpan',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocForm(kandangId: widget.kandangId),
                  ),
                ).then((value) {
                  if (value == true) {
                    fetchDocData();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF82985E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tambah DOC'),
            ),
          ],
        ),
      );
    }

    // Display DOC data as a list
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchDocData,
            color: const Color(0xFF82985E),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docList.length,
              itemBuilder: (context, index) {
                final item = docList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with colored background
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF82985E).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(
                                0xFF82985E,
                              ).withOpacity(0.2),
                              radius: 20,
                              child: const Icon(
                                Icons.baby_changing_station,
                                color: Color(0xFF82985E),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Data DOC',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Color(0xFF82985E),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => DocForm(
                                            kandangId: widget.kandangId,
                                            docToEdit: item['raw_data'],
                                          ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      fetchDocData();
                                    }
                                  });
                                } else if (value == 'delete') {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Hapus Data DOC'),
                                          content: const Text(
                                            'Apakah Anda yakin ingin menghapus data DOC ini?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteItem(
                                                  item['id'].toString(),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                  );
                                } else if (value == 'detail') {
                                  _showDetailDialog(item);
                                }
                              },
                              itemBuilder:
                                  (
                                    BuildContext context,
                                  ) => <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'detail',
                                      child: Row(
                                        children: [
                                          Icon(Icons.info_outline, size: 20),
                                          SizedBox(width: 8),
                                          Text('Detail'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hapus',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              icon: Icons.scale,
                              label: 'Bobot Awal',
                              value: '${item['bobot_awal']} kg',
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.groups,
                              label: 'Populasi Awal',
                              value: '${item['populasi_awal']} ekor',
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.error_outline,
                              label: 'Kematian',
                              value: '${item['kematian']} ekor',
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.check_circle_outline,
                              label: 'Populasi Akhir',
                              value: '${item['populasi_akhir']} ekor',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocForm(kandangId: widget.kandangId),
                ),
              ).then((value) {
                if (value == true) {
                  fetchDocData();
                }
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah DOC'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82985E),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Detail DOC'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('Bobot Awal', '${item['bobot_awal']} kg'),
                  _buildDetailItem(
                    'Populasi Awal',
                    '${item['populasi_awal']} ekor',
                  ),
                  _buildDetailItem('Kematian', '${item['kematian']} ekor'),
                  const Divider(),
                  _buildDetailItem(
                    'Populasi Akhir',
                    '${item['populasi_akhir']} ekor',
                    isBold: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}
