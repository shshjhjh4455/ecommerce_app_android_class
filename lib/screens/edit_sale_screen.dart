import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSaleScreen extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const EditSaleScreen({Key? key, required this.saleData}) : super(key: key);

  @override
  _EditSaleScreenState createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends State<EditSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  late bool _isSold;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.saleData['price'].toString());
    _isSold = widget.saleData['isSold'] ?? false;
  }

  Future<void> _saveSale() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return; // 폼이 유효하지 않으면 저장하지 않음
    }

    try {
      // Firestore 문서 업데이트
      String docId = widget.saleData['id'];
      if (docId.isEmpty) {
        throw Exception('문서 ID가 없습니다.');
      }
      await _firestore.collection('sales').doc(docId).update({
        'price': int.parse(_priceController.text),
        'isSold': _isSold,
      });
      Navigator.of(context).pop(); // 성공적으로 업데이트 후 이전 화면으로 돌아가기
    } catch (e) {
      // 에러 처리
      final snackBar = SnackBar(content: Text('저장 실패: ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('판매 글 수정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? '가격을 입력하세요' : null,
              ),
              SwitchListTile(
                title: Text('판매 상태: ${_isSold ? '판매 완료' : '판매 중'}'),
                value: _isSold,
                onChanged: (bool value) {
                  setState(() {
                    _isSold = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSale,
                child: const Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
