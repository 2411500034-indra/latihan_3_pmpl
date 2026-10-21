import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notes_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).startListening();
    });
  }

  void _showNoteDialog({NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController =
        TextEditingController(text: note?.content ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Tambah Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final notes =
                  Provider.of<NotesProvider>(context, listen: false);
              if (note == null) {
                notes.addNote(titleController.text, contentController.text);
              } else {
                notes.updateNote(
                    note.id, titleController.text, contentController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notes, _) {
          switch (notes.state) {
            case ViewState.loading:
              return const Center(child: CircularProgressIndicator());
            case ViewState.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: ${notes.errorMessage}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => notes.refreshOnce(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            case ViewState.empty:
              return const Center(child: Text('Belum ada note.'));
            case ViewState.loaded:
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: notes.notes.length,
                itemBuilder: (context, index) {
                  final note = notes.notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note.title),
                      subtitle: Text(note.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit note',
                            onPressed: () => _showNoteDialog(note: note),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Hapus note',
                            onPressed: () => notes.deleteNote(note.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
