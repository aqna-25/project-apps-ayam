import 'package:flutter/material.dart';

class DetailRekapitulasi extends StatelessWidget {
  const DetailRekapitulasi({Key? key}) : super(key: key);

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
