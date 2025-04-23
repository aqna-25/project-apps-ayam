import 'package:flutter/material.dart';
import 'tambahsapronakform.dart';
import 'tambahpanenform.dart';

class DetailKandangPage extends StatefulWidget {
  const DetailKandangPage({super.key});

  @override
  State<DetailKandangPage> createState() => _DetailKandangPageState();
}

class _DetailKandangPageState extends State<DetailKandangPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82985E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        title: const Text('banbang', style: TextStyle(color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: const Color(0xFF77875E),
          unselectedLabelColor: Colors.grey,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: const Color(0xFF77875E), width: 2.0),
            ),
          ),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Sapronak'),
            Tab(text: 'Panen'),
            Tab(text: 'Rekapitulasi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RingkasanTab(),
          _SapronakTab(),
          _PanenTab(),
          _RekapitulasiTab(),
        ],
      ),
    );
  }
}

class _RingkasanTab extends StatelessWidget {
  const _RingkasanTab();

  @override
  Widget build(BuildContext context) {
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
                    _buildInfoCard('Periode', '1', Colors.redAccent),
                    _buildInfoCard('Umur', '0 Hari', Colors.lightBlueAccent),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoCard('Panen', '0 Ekor', Colors.greenAccent),
                    _buildInfoCard(
                      'DOC In',
                      '23 Apr 2025',
                      Colors.orangeAccent,
                    ),
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
              children: const [
                Text(
                  'Informasi ayam',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Jenis DOC'), Text('DOC AYAM UNGGUL NV')],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Bobot awal'), Text('1 g')],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Populasi awal'), Text('Populasi sekarang')],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('60 ekor'), Text('60 ekor')],
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
}

Widget _buildInfoCard(String title, String value, Color color) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()), // Gunakan withAlpha()
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SapronakTab extends StatelessWidget {
  const _SapronakTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Belum ada data sapronak tersimpan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahSapronakForm(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82985E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah sapronak'),
          ),
        ],
      ),
    );
  }
}

class _PanenTab extends StatelessWidget {
  const _PanenTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Belum ada data panen tersimpan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TambahPanenForm(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82985E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah panen'),
          ),
        ],
      ),
    );
  }
}

class _RekapitulasiTab extends StatelessWidget {
  const _RekapitulasiTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
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
                  'Rp -8.895.601',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
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
          _buildRekapitulasiItem('DOC', 'Rp 120.000'),
          _buildRekapitulasiItem('Pakan', 'Rp 515.400'),
          _buildRekapitulasiItem('OVK', 'Rp 8.260.201'),
          const SizedBox(height: 8),
          const Divider(),
          _buildRekapitulasiItem(
            'Total pengeluaran',
            'Rp 8.895.601',
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          const Text(
            'Penjualan livebird',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildRekapitulasiItem('Pendapatan per ekor', 'Rp 0'),
          _buildRekapitulasiItem(
            'Total penjualan',
            'Rp 0',
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
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
