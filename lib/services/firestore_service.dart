import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 데이터 추가
  Future<void> addData(String collectionPath, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).add(data);
  }

  // 특정 문서 데이터 읽기
  Future<DocumentSnapshot> getData(String documentPath) async {
    return await _firestore.doc(documentPath).get();
  }

  // 컬렉션의 모든 문서 데이터 스트림 반환
  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  // 데이터 수정
  Future<void> updateData(
      String documentPath, Map<String, dynamic> data) async {
    await _firestore.doc(documentPath).update(data);
  }

  // 데이터 삭제
  Future<void> deleteData(String documentPath) async {
    await _firestore.doc(documentPath).delete();
  }
}
