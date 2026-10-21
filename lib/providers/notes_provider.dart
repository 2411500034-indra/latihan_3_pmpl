import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import 'data_provider.dart' show ViewState;

// Agar layar yang meng-import notes_provider.dart langsung bisa memakai
// ViewState tanpa import tambahan (sesuai home_screen contoh dosen).
export 'data_provider.dart' show ViewState;

class NotesProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // State, data, dan pesan error (pola ViewState seperti Pertemuan 3).
  ViewState _state = ViewState.initial;
  List<NoteModel> _notes = [];
  String _errorMessage = '';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  ViewState get state => _state;
  List<NoteModel> get notes => _notes;
  String get errorMessage => _errorMessage;

  // Mendaftarkan listener ke stream Firestore. Setiap ada data baru,
  // provider memanggil notifyListeners() sehingga UI ter-refresh otomatis.
  void startListening() {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();
    _subscribe();
  }

  // Ambil data satu kali (get), lalu aktifkan kembali stream realtime.
  // Dipakai tombol "Coba Lagi": stream Firestore berhenti setelah error,
  // jadi harus didaftarkan ulang agar data kembali live.
  Future<void> refreshOnce() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final snapshot = await _service.getNotes();
      _applyDocs(snapshot.docs);
    } catch (e) {
      _errorMessage = _pesanError(e);
      _state = ViewState.error;
      notifyListeners();
      return;
    }
    _subscribe();
  }

  // Batalkan langganan lama dulu agar tidak ada stream ganda
  // (misalnya setelah logout lalu login kembali).
  void _subscribe() {
    _subscription?.cancel();
    _subscription = _service.streamNotes().listen(
      (snapshot) => _applyDocs(snapshot.docs),
      onError: (Object e) {
        _errorMessage = _pesanError(e);
        _state = ViewState.error;
        notifyListeners();
      },
    );
  }

  void _applyDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final result = docs.map(NoteModel.fromSnapshot).toList();
    // Urutkan terbaru di atas, dilakukan di Dart (tanpa orderBy Firestore).
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _notes = result;
    _state = result.isEmpty ? ViewState.empty : ViewState.loaded;
    _errorMessage = '';
    notifyListeners();
  }

  // Operasi tulis mengembalikan null jika sukses, atau pesan error.
  // Daftar tidak perlu di-refresh manual: stream otomatis memperbarui UI.
  Future<String?> addNote(String title, String content) async {
    try {
      await _service.addNote(title, content);
      return null;
    } catch (e) {
      return _pesanError(e);
    }
  }

  Future<String?> updateNote(String id, String title, String content) async {
    try {
      await _service.updateNote(id, title, content);
      return null;
    } catch (e) {
      return _pesanError(e);
    }
  }

  Future<String?> deleteNote(String id) async {
    try {
      await _service.deleteNote(id);
      return null;
    } catch (e) {
      return _pesanError(e);
    }
  }

  String _pesanError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Akses ditolak. Aktifkan Test Mode pada Rules Firestore '
              'Database di Firebase Console.';
        case 'failed-precondition':
          return 'Query membutuhkan Composite Index. Hapus orderBy() atau '
              'buat index lewat URL pada pesan error.';
        case 'unavailable':
          return 'Tidak ada koneksi internet / server tidak terjangkau.';
        default:
          return e.message ?? 'Terjadi kesalahan pada Firestore.';
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  // Membatalkan langganan stream saat provider dibuang
  // untuk mencegah kebocoran memori (memory leak).
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
