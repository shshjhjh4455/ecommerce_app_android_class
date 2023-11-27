import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_sale_screen.dart';
import 'sales_detail_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showSoldItems = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매 글 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _showSoldItems = !_showSoldItems;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('sales')
            .where('isSold', isEqualTo: _showSoldItems)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('오류가 발생했습니다.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(
                    '${data['price']}원, 판매 ${data['isSold'] ? '완료' : '중'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SalesDetailScreen(saleData: data),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 판매 글 작성 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateSaleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
