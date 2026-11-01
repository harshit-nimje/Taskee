import 'package:bloc/bloc.dart';
import 'package:taskee/features/note/domain/model/note_list_model.dart';
import 'package:taskee/features/note/domain/usecase/add_note.dart';
import 'package:taskee/features/note/domain/usecase/delete_note.dart';
import 'package:taskee/features/note/domain/usecase/get_all_notes.dart';
import 'package:taskee/features/note/domain/usecase/update_note.dart';
import 'package:taskee/features/note/presentation/bloc/note_event.dart';
import 'package:taskee/features/note/presentation/bloc/note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetAllNotes getAllNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  NoteBloc({
    required this.getAllNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(NoteLoadingState()) {
    on<NoteStartedEvent>(_onStarted);
    on<NoteItemAddedEvent>(_onItemAdded);
    on<NoteItemUpdatedEvent>(_onItemUpdated);
    on<NoteItemDeletedEvent>(_onItemDeleted);
  }

  void _emitCurrentList(Emitter<NoteState> emit) {
    emit(NoteLoadedState(NoteListModel(noteList: getAllNotes())));
  }

  void _onStarted(NoteStartedEvent event, Emitter<NoteState> emit) {
    try {
      emit(NoteLoadingState());
      _emitCurrentList(emit);
    } catch (_) {
      emit(const NoteErrorState());
    }
  }

  Future<void> _onItemAdded(
    NoteItemAddedEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await addNote(event.note);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const NoteErrorState());
    }
  }

  Future<void> _onItemUpdated(
    NoteItemUpdatedEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await updateNote(event.note);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const NoteErrorState());
    }
  }

  Future<void> _onItemDeleted(
    NoteItemDeletedEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await deleteNote(event.id);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const NoteErrorState());
    }
  }
}
