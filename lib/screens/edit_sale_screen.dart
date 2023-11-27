import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSaleScreen extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const EditSaleScreen({super.key, required this.saleData});

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

  void _saveSale() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Firestore 문서 업데이트
        await _firestore.collection('sales').doc(widget.saleData['id']).update({
          'price': int.parse(_priceController.text),
          'isSold': _isSold,
        });
        Navigator.of(context).pop(); // 이전 화면으로 돌아가기
      } catch (e) {
        // 에러 처리: 예를 들어, 사용자에게 에러 메시지를 보여줄 수 있습니다.
        print(e); // 콘솔에 에러 출력
      }
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
