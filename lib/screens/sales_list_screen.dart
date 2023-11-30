import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_sale_screen.dart';
import 'sales_detail_screen.dart';
import 'chat_management_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({Key? key}) : super(key: key);

  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showSoldItems = false;
  bool _showMyItemsOnly = false;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = _auth.currentUser?.email;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('필터 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('모두 보기'),
                onTap: () {
                  setState(() {
                    _showSoldItems = false;
                    _showMyItemsOnly = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('판매 완료만 보기'),
                onTap: () {
                  setState(() {
                    _showSoldItems = true;
                    _showMyItemsOnly = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('판매 중만 보기'),
                onTap: () {
                  setState(() {
                    _showSoldItems = false;
                    _showMyItemsOnly = false;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _buildStream() {
    Query<Map<String, dynamic>> query = _firestore.collection('sales');

    if (_showMyItemsOnly && _currentUserEmail != null) {
      query = query.where('seller', isEqualTo: _currentUserEmail);
    }

    if (_showSoldItems) {
      query = query.where('isSold', isEqualTo: true);
    } else if (!_showMyItemsOnly) {
      query = query.where('isSold', isEqualTo: false);
    }

    return query.snapshots();
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매 글 목록', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
          Switch(
            value: _showMyItemsOnly,
            onChanged: (value) {
              setState(() {
                _showMyItemsOnly = value;
              });
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        ),
      ),
      body: StreamBuilder(
        stream: _buildStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('오류가 발생했습니다.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> itemList = [];

          if (_showMyItemsOnly) {
            itemList.add(
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blueGrey,
                child: const Text(
                  '내 글만 보기',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          }

          itemList.addAll(snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            data['id'] = document.id;

            return Card(
              child: ListTile(
                title: Text(data['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
              ),
            );
          }).toList());

          return ListView(children: itemList);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const ChatManagementScreen()),
              );
            },
            heroTag: 'chat',
            child: const Icon(Icons.chat),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const CreateSaleScreen()),
              );
            },
            heroTag: 'add',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
