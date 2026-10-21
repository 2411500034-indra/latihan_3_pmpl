import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NoteModel.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final createdAt = ts is Timestamp ? ts : Timestamp.now();

    return NoteModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      createdAt: createdAt,
    );
  }

  factory NoteModel.fromFirestore(DocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NoteModel.fromMap(doc.id, data);
  }

  factory NoteModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return NoteModel.fromMap(doc.id, doc.data());
  }
}