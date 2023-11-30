import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_sale_screen.dart'; // 판매 글 수정 화면

class SalesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const SalesDetailScreen({Key? key, required this.saleData}) : super(key: key);

  @override
  _SalesDetailScreenState createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkAndNavigateToEditScreen();
  }

  void _checkAndNavigateToEditScreen() {
    User? currentUser = _auth.currentUser;
    if (currentUser?.email == widget.saleData['seller']) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EditSaleScreen(saleData: widget.saleData),
          ),
        );
      });
    }
  }

  void _sendMessageToSeller() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController messageController = TextEditingController();
        return AlertDialog(
          title: const Text('메시지 보내기'),
          content: TextField(
            controller: messageController,
            decoration: const InputDecoration(hintText: "여기에 메시지를 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('보내기'),
              onPressed: () async {
                String message = messageController.text;
                if (message.isNotEmpty) {
                  await _firestore.collection('messages').add({
                    'sellerEmail': widget.saleData['seller'],
                    'buyerEmail': _auth.currentUser?.email,
                    'message': message,
                    'saleId': widget.saleData['id'], // 판매 글의 ID
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saleData['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              Text(
                '제목: ${widget.saleData['title']}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('가격: ${widget.saleData['price']}원'),
              const SizedBox(height: 8),
              Text('판매 상태: ${widget.saleData['isSold'] ? '판매 완료' : '판매 중'}'),
              const SizedBox(height: 8),
              Text('판매자: ${widget.saleData['seller']}'),
              const SizedBox(height: 16),
              Text('내용: ${widget.saleData['description']}'),
              if (currentUser?.email != widget.saleData['seller'])
                ElevatedButton(
                  onPressed: _sendMessageToSeller,
                  child: const Text('판매자에게 메시지 보내기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
