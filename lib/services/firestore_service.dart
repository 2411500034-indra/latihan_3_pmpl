import 'package:cloud_firestore/cloud_firestore.dart';

// Akses langsung ke Cloud Firestore (collection "notes").
// Tidak ada logika UI/state di sini: hanya operasi CRUD.
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _notes =
      FirebaseFirestore.instance.collection('notes');

  // READ (realtime): stream berkelanjutan. Sengaja TANPA orderBy() agar
  // tidak memicu error Composite Index. Pengurutan dilakukan di NotesProvider.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNotes() {
    return _notes.snapshots();
  }

  // READ (sekali ambil): Future, koneksi ditutup setelah hasil diterima.
  Future<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    return _notes.get();
  }

  // CREATE: dokumen baru dengan auto ID acak dari Firestore.
  Future<void> addNote(String title, String content) {
    return _notes.add({
      'title': title,
      'content': content,
      'createdAt': Timestamp.now(),
    });
  }

  // UPDATE: hanya field tertentu, field lain (createdAt) tidak disentuh.
  Future<void> updateNote(String id, String title, String content) {
    return _notes.doc(id).update({
      'title': title,
      'content': content,
    });
  }

  // DELETE: hapus dokumen secara permanen dari koleksi.
  Future<void> deleteNote(String id) {
    return _notes.doc(id).delete();
  }
}
