import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectayam/activate_kandang.dart';
import 'package:projectayam/detailkandang.dart';
import 'profil.dart';
import 'addkandang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Kandang {
  final int id;
  final String namaKandang;
  final String kapasitasKandang;
  final String jenisKandang;
  final String tingkatKandang;
  final String provinsi;
  final String kota;
  final String statusKandang;
  final String alamatKandang;
  final int userId;
  Kandang({
    required this.id,
    required this.namaKandang,
    required this.kapasitasKandang,
    required this.jenisKandang,
    required this.tingkatKandang,
    required this.provinsi,
    required this.kota,
    required this.statusKandang,
    required this.alamatKandang,
    required this.userId,
  });
  factory Kandang.fromJson(Map<String, dynamic> json) {
    return Kandang(
      id: json['id'],
      namaKandang: json['nama_kandang'],
      kapasitasKandang: json['kapasitas_kandang'],
      jenisKandang: json['jenis_kandang'],
      tingkatKandang: json['tingkat_kandang'],
      provinsi: json['provinsi'],
      kota: json['kota'],
      statusKandang: json['status_kandang'],
      alamatKandang: json['alamat_kandang'] ?? '',
      userId: json['user_id'] ?? 0,
    );
  }
}

class KandangPage extends StatefulWidget {
  const KandangPage({super.key});
  @override
  State<KandangPage> createState() => _KandangPageState();
}

class _KandangPageState extends State<KandangPage> {
  List<Kandang> kandangList = [];
  List<Kandang> filteredKandangList = []; // Tambahkan list terfilter
  bool isLoading = true;
  String searchQuery = '';
  TextEditingController searchController =
      TextEditingController(); // Tambahkan controller untuk search
  String? errorMessage;
  int? userId;
  @override
  void initState() {
    super.initState();
    getUserData().then((_) => fetchKandangData());
  }

  @override
  void dispose() {
    searchController.dispose(); // Tambahkan dispose untuk controller
    super.dispose();
  }

  Future<void> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getInt('user_id');
      });
      if (userId == null) {
        print('User ID tidak ditemukan di SharedPreferences');
      } else {
        print('User ID yang sedang login: $userId');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  Future<void> fetchKandangData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) {
        setState(() {
          errorMessage =
              'Sesi login Anda telah berakhir. Silakan login kembali.';
          isLoading = false;
        });
        return;
      }
      final response = await http
          .get(
            Uri.parse('https://ayamku.web.id/api/kandangs'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Periksa koneksi internet Anda.',
              );
            },
          );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          List<Kandang> allKandangs = List<Kandang>.from(
            data['data'].map((kandang) => Kandang.fromJson(kandang)),
          );
          if (userId != null) {
            setState(() {
              kandangList =
                  allKandangs
                      .where((kandang) => kandang.userId == userId)
                      .toList();
              filteredKandangList = List.from(
                kandangList,
              ); // Inisialisasi list terfilter
              isLoading = false;
            });
            print('Jumlah kandang milik user: ${kandangList.length}');
          } else {
            setState(() {
              kandangList = [];
              filteredKandangList = [];
              errorMessage =
                  'Tidak dapat mengidentifikasi user yang sedang login';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            kandangList = [];
            filteredKandangList = [];
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage =
              'Sesi login Anda telah berakhir. Silakan login kembali.';
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data kandang: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching kandang data: $e');
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error retrieving auth token: $e');
      return null;
    }
  }

  // Implementasi fungsi pencarian yang lebih baik
  void filterKandangList(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredKandangList = List.from(kandangList);
      } else {
        filteredKandangList =
            kandangList
                .where(
                  (kandang) =>
                      kandang.namaKandang.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      kandang.jenisKandang.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      kandang.kota.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      kandang.provinsi.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      kandang.statusKandang.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("Assets/kandang.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                filterKandangList('');
                              },
                            )
                            : null,
                    hintText: 'Cari Kandang',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    filterKandangList(value);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                        ? _buildErrorView(errorMessage!)
                        : filteredKandangList.isEmpty
                        ? _buildEmptyKandangView(context)
                        : _buildKandangListView(filteredKandangList),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFFEF6F4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home),
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart),
                color: Colors.black,
                onPressed: () {}, // Current page
              ),
              IconButton(
                icon: const Icon(Icons.person),
                color: Colors.black,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Profil()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8AA653),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddKandangPage()),
          ).then((_) => fetchKandangData());
        },
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8AA653),
              ),
              onPressed: fetchKandangData,
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyKandangView(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.brown[700]?.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Anda belum memiliki kandang",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8AA653),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddKandangPage()),
                ).then((_) => fetchKandangData());
              },
              child: const Text(
                "Buat Kandang",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKandangListView(List<Kandang> kandangList) {
    return RefreshIndicator(
      onRefresh: fetchKandangData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kandangList.length,
        itemBuilder: (context, index) {
          final kandang = kandangList[index];
          final bool isActive = kandang.statusKandang.toLowerCase() == 'aktif';
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            color: Colors.brown[700]?.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          kandang.namaKandang,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(kandang.statusKandang),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kandang.statusKandang,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.category,
                    'Jenis: ${kandang.jenisKandang}',
                  ),
                  _buildInfoRow(
                    Icons.layers,
                    'Tingkat: ${kandang.tingkatKandang}',
                  ),
                  _buildInfoRow(
                    Icons.people,
                    'Kapasitas: ${kandang.kapasitasKandang}',
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    '${kandang.kota}, ${kandang.provinsi}',
                  ),
                  if (kandang.alamatKandang.isNotEmpty)
                    _buildInfoRow(Icons.home, kandang.alamatKandang),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Show Edit button if status is Active
                      if (isActive)
                        TextButton.icon(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            'Edit',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DetailKandangPage(
                                      kandangId: kandang.id.toString(),
                                    ),
                              ),
                            ).then((_) => fetchKandangData());
                          },
                        ),
                      // Show Activation button if status is not Active
                      if (!isActive)
                        TextButton.icon(
                          icon: const Icon(
                            Icons.power_settings_new,
                            color: Colors.green,
                          ),
                          label: const Text(
                            'Aktivasi',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _showActivationConfirmation(context, kandang);
                          },
                        ),
                      // Delete button is always shown
                      TextButton.icon(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _showDeleteConfirmation(context, kandang);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showActivationConfirmation(BuildContext context, Kandang kandang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aktivasi Kandang'),
          content: Text(
            'Apakah Anda yakin ingin mengaktifkan kandang "${kandang.namaKandang}"?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8AA653),
              ),
              child: const Text('Aktivasi'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AktivasiKandangPage(kandangId: kandang.id),
                  ),
                ).then((_) => fetchKandangData()); // Refresh after returning
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green;
      case 'nonaktif':
        return Colors.red;
      case 'pemeliharaan':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Kandang kandang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kandang "${kandang.namaKandang}"?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKandang(kandang.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteKandang(int kandangId) async {
    setState(() {
      isLoading = true;
    });
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) {
        throw Exception('Authentication token not found');
      }
      final response = await http
          .delete(
            Uri.parse('https://ayamku.web.id/api/kandangs/$kandangId'),
            headers: {
              'Authorization': 'Bearer $authToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Koneksi timeout. Periksa koneksi internet Anda.',
              );
            },
          );
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success, refresh the list
        fetchKandangData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kandang berhasil dihapus')),
        );
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage =
              'Sesi login Anda telah berakhir. Silakan login kembali.';
        });
        // Handle token expiration - redirect to login
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal menghapus kandang');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error deleting kandang: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kandang: ${e.toString()}')),
      );
    }
  }
}
