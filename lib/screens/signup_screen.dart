import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _birthDate = '';

  void _trySignUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: _email, password: _password);
      if (userCredential.user != null) {
        // 추가: 사용자 이름 및 생년월일 정보 저장 로직 구현 필요

        // 회원가입 성공 후, 판매 글 목록 페이지로 이동
        Navigator.of(context).pushReplacementNamed('/salesList');
      }
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return '유효한 이메일을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                onSaved: (value) => _password = value!,
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return '6자 이상의 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '이름'),
                onSaved: (value) => _name = value!,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '생년월일 (YYYYMMDD)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _birthDate = value!,
                validator: (value) {
                  if (value!.isEmpty ||
                      value.length != 8 ||
                      !RegExp(r'^\d{8}$').hasMatch(value)) {
                    return '8자리 숫자의 생년월일을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _trySignUp,
                child: const Text('가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
