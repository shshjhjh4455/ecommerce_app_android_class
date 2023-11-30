import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 및 시간 형식을 위한 패키지

class ChatManagementScreen extends StatefulWidget {
  const ChatManagementScreen({super.key});

  @override
  _ChatManagementScreenState createState() => _ChatManagementScreenState();
}

class _ChatManagementScreenState extends State<ChatManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _initMessagesStream();
  }

  void _initMessagesStream() {
    String? currentUserEmail = _auth.currentUser?.email;
    if (currentUserEmail != null) {
      _messagesStream = _firestore
          .collection('messages')
          .where('sellerEmail', isEqualTo: currentUserEmail)
          .orderBy('timestamp', descending: true)
          .snapshots();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd – HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('받은 메시지'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _messagesStream == null
          ? const Center(child: Text('로그인 정보를 확인해주세요.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('StreamBuilder 오류: ${snapshot.error}');
                  return Text('오류가 발생했습니다: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('받은 메시지가 없습니다.'));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    String formattedTime = _formatTimestamp(data['timestamp']);
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          data['message'] ?? '메시지 없음',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('보낸 사람: ${data['buyerEmail'] ?? '알 수 없음'}'),
                            Text('시간: $formattedTime'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
