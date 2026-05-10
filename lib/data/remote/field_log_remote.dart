import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/field_log.dart';

class FieldLogRemote {
  final _fs = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _fs.collection('logs').doc(userId).collection('entries');

  Future<void> upsert(FieldLog log) async {
    await _col(log.userId!).doc(log.id).set(log.toJson());
  }

  Future<void> delete(String userId, String logId) async {
    await _col(userId).doc(logId).delete();
  }

  Future<List<FieldLog>> fetchAll(String userId) async {
    final snap = await _col(
      userId,
    ).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => FieldLog.fromJson(d.data())).toList();
  }
}
