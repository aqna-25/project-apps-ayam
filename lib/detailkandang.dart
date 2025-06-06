import 'package:flutter/material.dart';

import 'package:projectayam/pages/detail_panen.dart';
import 'package:projectayam/pages/detail_rekapitulasi.dart';
import 'package:projectayam/pages/detail_ringkasan.dart';
import 'package:projectayam/pages/detail_sapronak.dart';

class DetailKandangPage extends StatefulWidget {
  final int kandangId;

  const DetailKandangPage({required this.kandangId, Key? key})
    : super(key: key);

  @override
  State<DetailKandangPage> createState() => _DetailKandangPageState();
}

class _DetailKandangPageState extends State<DetailKandangPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text(
          'Detail Kandang',
          style: TextStyle(color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: const Color(0xFF77875E),
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFF77875E), width: 2.0),
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
        children: [
          const DetailRingkasan(),
          DetailSapronak(kandangId: widget.kandangId),
          const DetailPanen(),
          const DetailRekapitulasi(),
        ],
      ),
    );
  }
}
