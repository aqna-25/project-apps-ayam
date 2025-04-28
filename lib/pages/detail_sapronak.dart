import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:projectayam/pages/form/pakans.dart';
import 'package:projectayam/pages/form/vaksins.dart';

class DetailSapronak extends StatefulWidget {
  final String kandangId;
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
      print('Kandang ID: ${widget.kandangId}');
      final response = await http.get(
        Uri.parse('https://ayamku.web.id/api/kandangs/${widget.kandangId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']; // Akses objek 'data'
        print('API Response: $data'); // Log respons API

        // Proses data pakan
        if (data['pakan'] != null) {
          pakanList = List<Map<String, dynamic>>.from(
            data['pakan'].map(
              (item) => {
                'nama': item['produk'] ?? 'Tidak ada nama',
                'jumlah': '${item['kuantitas'] ?? 0} kg',
                'tanggal': _formatDate(item['tgl_masuk'] ?? ''),
                'id': item['id']?.toString() ?? '',
                'raw_data': item,
              },
            ),
          );
        } else {
          pakanList = [];
          print('No pakan data found in API response');
        }

        // Proses data vaksin
        if (data['vaksin'] != null) {
          vaksinList = List<Map<String, dynamic>>.from(
            data['vaksin'].map(
              (item) => {
                'nama': item['jenis_vaksin'] ?? 'Tidak ada nama',
                'dosis': '${item['kuantitas'] ?? 0} dosis',
                'tanggal': _formatDate(item['tgl_vaksin'] ?? ''),
                'id': item['id']?.toString() ?? '',
                'raw_data': item,
              },
            ),
          );
        } else {
          vaksinList = [];
          print('No vaksin data found in API response');
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
      print('Exception occurred: $e');
      setState(() {
        errorMessage = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  // Helper method to format date from API (YYYY-MM-DD) to display format (DD/MM/YYYY)
  String _formatDate(String apiDate) {
    try {
      if (apiDate.isEmpty) return '';

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
                        Icons.food_bank, // Updated: removed 'outlined'
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PakanForm(kandangId: widget.kandangId),
                          ),
                        ).then((_) => fetchSapronakData()),
                        onDelete: (String id) async {
                          await _deleteItem('pakan', id);
                        },
                        onEdit: (Map<String, dynamic> item) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => PakanForm(
                                    kandangId: widget.kandangId,
                                    pakanToEdit:
                                        item['raw_data'], // Fixed: Changed 'rawdata' to 'raw_data'
                                  ),
                            ),
                          ).then((_) => fetchSapronakData());
                        },
                      ),
                      // Tab 2: Vaksin
                      _buildDataList(
                        vaksinList,
                        'vaksin',
                        Icons.medical_services, // Updated: removed 'outlined'
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VaksinForm(
                                  kandangId: widget.kandangId,
                                  onSave: () {
                                    fetchSapronakData();
                                  },
                                ),
                          ),
                        ).then((_) => fetchSapronakData()),
                        onDelete: (String id) async {
                          await _deleteItem('vaksin', id);
                        },
                        onEdit: (Map<String, dynamic> item) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => VaksinForm(
                                    kandangId: widget.kandangId,
                                    vaksinToEdit:
                                        item['raw_data'], // Fixed: Changed 'rawdata' to 'raw_data'
                                    onSave: () {
                                      fetchSapronakData();
                                    },
                                  ),
                            ),
                          ).then((_) => fetchSapronakData());
                        },
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  // Helper method to delete items
  Future<void> _deleteItem(String type, String id) async {
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

  // Ganti fungsi _buildDataList dengan kode berikut untuk card yang lebih baik

  Widget _buildDataList(
    List<Map<String, dynamic>> data,
    String type,
    IconData icon,
    VoidCallback onAddPressed, {
    required Function(String) onDelete,
    required Function(Map<String, dynamic>) onEdit,
  }) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                              child: Icon(
                                icon,
                                color: const Color(0xFF82985E),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['nama'],
                                style: const TextStyle(
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
                                  onEdit(item);
                                } else if (value == 'delete') {
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
                                                  () => Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                onDelete(item['id'].toString());
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        ),
                                  );
                                }
                              },
                              itemBuilder:
                                  (
                                    BuildContext context,
                                  ) => <PopupMenuEntry<String>>[
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
                              icon:
                                  type == 'pakan'
                                      ? Icons.inventory_2
                                      : Icons.medical_information,
                              label: type == 'pakan' ? 'Jumlah' : 'Dosis',
                              value:
                                  type == 'pakan'
                                      ? item['jumlah']
                                      : item['dosis'],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              icon: Icons.calendar_today,
                              label: 'Tanggal',
                              value: item['tanggal'],
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
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: Text('Tambah $type'),
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

  // Tambahkan fungsi helper ini untuk menampilkan detail row
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
