import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SalesDetailScreen extends StatelessWidget {
  final Map<String, dynamic> saleData;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SalesDetailScreen({super.key, required this.saleData});

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(saleData['title']),
        actions: currentUser?.email == saleData['sellerEmail']
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // 판매 글 수정 페이지로 이동
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    // Firestore에서 해당 판매 글 삭제
                    await _firestore
                        .collection('sales')
                        .doc(saleData['id'])
                        .delete();
                    Navigator.pop(context);
                  },
                ),
              ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 이미지 url 해당 소스코드 변경필요함
              if (saleData['imageUrl'] != null)
                Image.network(saleData['imageUrl']),
              const SizedBox(height: 8),
              Text(
                '제목: ${saleData['title']}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('가격: ${saleData['price']}원'),
              const SizedBox(height: 8),
              Text('판매 상태: ${saleData['isSold'] ? '판매 완료' : '판매 중'}'),
              const SizedBox(height: 8),
              Text('판매자: ${saleData['seller']}'),
              const SizedBox(height: 16),
              Text('내용: ${saleData['description']}'),
              if (currentUser?.email != saleData['sellerEmail'])
                ElevatedButton(
                  child: const Text('판매자에게 메시지 보내기'),
                  onPressed: () {
                    // 메시지 보내기 기능 구현
                    // 예를 들어, 메시지 보내기 페이지 또는 다이얼로그로 이동
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
