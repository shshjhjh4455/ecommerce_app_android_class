import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sales_list_screen.dart'; // 판매 글 목록 화면

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _tryLogin() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();
    try {
      // Firebase 인증을 사용하여 로그인
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      // 로그인 성공 시, 판매 글 목록 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SalesListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Firebase 인증 에러 처리
      final snackBar = SnackBar(content: Text('로그인 실패: ${e.message}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _tryLogin,
                child: const Text('로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
