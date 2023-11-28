import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_sale_screen.dart'; // 판매 글 수정 화면
import 'chat_screen.dart'; // 채팅 화면

class SalesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const SalesDetailScreen({Key? key, required this.saleData}) : super(key: key);

  @override
  _SalesDetailScreenState createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  final _auth = FirebaseAuth.instance;

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

  void _navigateToChatScreen() {
    User? currentUser = _auth.currentUser;
    String chatRoomId =
        _generateChatRoomId(currentUser?.email, widget.saleData['seller']);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoomId: chatRoomId),
      ),
    );
  }

  String _generateChatRoomId(String? user1, String? user2) {
    // 둘 중 하나라도 null이면 기본 채팅방 ID 반환
    if (user1 == null || user2 == null) {
      return 'default_chat_room';
    }

    // 둘 다 null이 아니면 고유한 채팅방 ID 생성
    return user1.compareTo(user2) > 0 ? '${user1}_$user2' : '${user2}_$user1';
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
                  onPressed: _navigateToChatScreen,
                  child: const Text('판매자에게 메시지 보내기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
