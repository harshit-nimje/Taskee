import 'package:taskee/features/note/domain/repository/note_repository.dart';

class DeleteNote {
  final NoteRepository repository;
  const DeleteNote(this.repository);

  Future<void> call(int id) => repository.deleteNote(id);
}
