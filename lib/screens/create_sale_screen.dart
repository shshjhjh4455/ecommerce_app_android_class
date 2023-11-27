import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSaleScreen extends StatefulWidget {
  const CreateSaleScreen({super.key});

  @override
  _CreateSaleScreenState createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _createSale() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('sales').add({
          'title': _titleController.text,
          'price': int.parse(_priceController.text),
          'description': _descriptionController.text,
          'seller': _auth.currentUser?.email,
          'isSold': false,
        });

        // Firestore에 저장 후, 판매 글 목록 화면으로 이동
        Navigator.of(context).pushReplacementNamed('/salesList');
      } catch (e) {
        // 에러 처리: 예를 들어, 에러 메시지를 표시할 수 있습니다.
        // 예: showDialog()를 사용하여 사용자에게 에러 메시지를 보여줍니다.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매 글 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                  validator: (value) =>
                      value == null || value.isEmpty ? '제목을 입력하세요' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: '가격'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '가격을 입력하세요';
                    }
                    if (int.tryParse(value) == null) {
                      return '유효한 숫자를 입력하세요';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: '내용'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) =>
                      value == null || value.isEmpty ? '내용을 입력하세요' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createSale,
                  child: const Text('등록하기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
