import 'package:taskee/features/note/domain/entities/note.dart';

abstract class NoteRepository {
  List<Note> getNoteList();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(int id);
}
