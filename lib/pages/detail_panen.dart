import 'package:flutter/material.dart';
import 'package:projectayam/pages/form/panen.dart';

class DetailPanen extends StatelessWidget {
  const DetailPanen({Key? key}) : super(key: key);

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
                MaterialPageRoute(builder: (context) => const PanenForm()),
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
