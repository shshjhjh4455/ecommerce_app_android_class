import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatManagementScreen extends StatefulWidget {
  const ChatManagementScreen({Key? key}) : super(key: key);

  @override
  _ChatManagementScreenState createState() => _ChatManagementScreenState();
}

class _ChatManagementScreenState extends State<ChatManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방 목록'),
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('chats')
            .doc('${currentUser?.email}_aaa@gmail.com')
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error); // 에러 출력
            return const Text('데이터를 불러오는 중 오류가 발생했습니다.');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // 로딩 인디케이터 표시
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('채팅이 없습니다'),
            );
          }

          // 데이터 처리 로직
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot chat = snapshot.data!.docs[index];
              return ListTile(
                title: Text(chat['text']),
                subtitle:
                    Text('보낸 사람: ${chat['sender']}\n시간: ${chat['timestamp']}'),
              );
            },
          );
        },
      ),
    );
  }
}
