import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectayam/pages/form/pakans.dart';
import 'package:projectayam/pages/form/vaksins.dart';

class DetailSapronak extends StatefulWidget {
  final int kandangId;

  const DetailSapronak({Key? key, required this.kandangId}) : super(key: key);

  @override
  State<DetailSapronak> createState() => _DetailSapronakState();
}

class _DetailSapronakState extends State<DetailSapronak>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> pakanList = [];
  List<Map<String, dynamic>> vaksinList = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchSapronakData();
  }

  Future<void> fetchSapronakData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/kandangs/${widget.kandangId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          // Periksa apakah data pakan ada dan bukan null sebelum menggunakan map
          if (data['pakan'] != null) {
            pakanList = List<Map<String, dynamic>>.from(
              data['pakan'].map(
                (item) => {
                  'nama': item['produk'],
                  'jumlah': '${item['kuantitas']} kg',
                  'tanggal': _formatDate(item['tgl_masuk']),
                  'id': item['id'],
                  'raw_data': item,
                },
              ),
            );
          } else {
            pakanList = []; // Set ke list kosong jika null
          }

          // Periksa apakah data vaksin ada dan bukan null sebelum menggunakan map
          if (data['vaksin'] != null) {
            vaksinList = List<Map<String, dynamic>>.from(
              data['vaksin'].map(
                (item) => {
                  'nama': item['jenis_vaksin'],
                  'dosis': '${item['kuantitas']} dosis',
                  'tanggal': _formatDate(item['tgl_vaksin']),
                  'id': item['id'],
                  'raw_data': item,
                },
              ),
            );
          } else {
            vaksinList = []; // Set ke list kosong jika null
          }

          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data. Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  // Helper method to format date from API (YYYY-MM-DD) to display format (DD/MM/YYYY)
  String _formatDate(String apiDate) {
    try {
      final parts = apiDate.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
      return apiDate; // Return original if not in expected format
    } catch (e) {
      return apiDate; // Return original on error
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar untuk navigasi antar Pakan dan Vaksin
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF82985E),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF82985E),
          tabs: const [Tab(text: 'Pakan'), Tab(text: 'Vaksin')],
        ),

        // Tab Bar View untuk menampilkan konten
        Expanded(
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF82985E)),
                  )
                  : errorMessage.isNotEmpty
                  ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Pakan
                      _buildDataList(
                        pakanList,
                        'pakan',
                        Icons.food_bank_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PakanForm(kandangId: widget.kandangId),
                          ),
                        ).then(
                          (_) => fetchSapronakData(),
                        ), // Refresh setelah kembali
                        onDelete: (int id) async {
                          await _deleteItem('pakan', id);
                        },
                        onEdit: (Map<String, dynamic> item) {
                          // Navigate to edit form with the item data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PakanForm(
                                    kandangId: widget.kandangId,
                                    pakanToEdit: item['raw_data'],
                                  ),
                            ),
                          ).then(
                            (_) => fetchSapronakData(),
                          ); // Refresh setelah kembali
                        },
                      ),

                      // Tab 2: Vaksin
                      _buildDataList(
                        vaksinList,
                        'vaksin',
                        Icons.medical_services_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VaksinForm(
                                  kandangId: widget.kandangId,
                                  onSave: () {
                                    // Refresh data after adding new vaksin
                                    fetchSapronakData();
                                  },
                                ),
                          ),
                        ).then(
                          (_) => fetchSapronakData(),
                        ), // Refresh setelah kembali
                        onDelete: (int id) async {
                          await _deleteItem('vaksin', id);
                        },
                        onEdit: (Map<String, dynamic> item) {
                          // Navigate to edit form with the item data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VaksinForm(
                                    kandangId: widget.kandangId,
                                    vaksinToEdit: item['raw_data'],
                                    onSave: () {
                                      // Refresh data after editing
                                      fetchSapronakData();
                                    },
                                  ),
                            ),
                          ).then(
                            (_) => fetchSapronakData(),
                          ); // Refresh setelah kembali
                        },
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  // Helper method to delete items
  Future<void> _deleteItem(String type, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://ayamku.web.id/api/${type}s/$id'),
      );

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$type berhasil dihapus')));
        // Refresh data
        fetchSapronakData();
      } else {
        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus $type')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: $e')));
    }
  }

  // Helper method untuk membangun list pakan atau vaksin
  Widget _buildDataList(
    List<Map<String, dynamic>> data,
    String type,
    IconData icon,
    VoidCallback onAddPressed, {
    required Function(int) onDelete,
    required Function(Map<String, dynamic>) onEdit,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Belum ada data $type tersimpan',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAddPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF82985E),
                foregroundColor: Colors.white,
              ),
              child: Text('Tambah $type'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: fetchSapronakData,
            color: const Color(0xFF82985E),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Icon(icon, color: const Color(0xFF82985E)),
                    title: Text(item['nama']),
                    subtitle: Text(
                      type == 'pakan'
                          ? 'Jumlah: ${item['jumlah']} • ${item['tanggal']}'
                          : 'Dosis: ${item['dosis']} • ${item['tanggal']}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Tampilkan menu untuk edit atau hapus
                        showModalBottomSheet(
                          context: context,
                          builder:
                              (context) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      onEdit(item);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    title: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Show confirmation dialog
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text('Hapus $type'),
                                              content: Text(
                                                'Apakah Anda yakin ingin menghapus ${item['nama']}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    onDelete(item['id']);
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: Text('Tambah $type'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82985E),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
