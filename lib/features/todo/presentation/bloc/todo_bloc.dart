import 'package:bloc/bloc.dart';
import 'package:taskee/features/todo/domain/entities/todo.dart';
import 'package:taskee/features/todo/domain/usecases/cancel_task_notification.dart';
import 'package:taskee/features/todo/domain/usecases/schedule_task_notification.dart';

import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_all_todos.dart';
import '../../domain/usecases/toggle_complete_todo.dart';
import '../../domain/usecases/undo_deleted_todo.dart';
import '../../domain/usecases/update_todo.dart';
import '../../domain/models/todo_list_model.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetAllTodos getAllTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final ToggleCompleteTodo toggleCompleteTodo;
  final DeleteTodo deleteTodo;
  final UndoDeletedTodo undoDeletedTodo;
  final ScheduleTaskNotification scheduleTaskNotification;
  final CancelTaskNotification cancelTaskNotification;

  TodoBloc({
    required this.getAllTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.toggleCompleteTodo,
    required this.deleteTodo,
    required this.undoDeletedTodo,
    required this.scheduleTaskNotification,
    required this.cancelTaskNotification,
  }) : super(TodoLoadingState()) {
    on<TodoStartedEvent>(_onStarted);
    on<TodoItemAddedEvent>(_onItemAdded);
    on<TodoItemUpdatedEvent>(_onItemUpdated);
    on<TodoItemToggleCompletedEvent>(_onItemToggleCompleted);
    on<TodoItemDeletedEvent>(_onItemDeleted);
    on<TodoItemUndoDeletedEvent>(_onItemUndoDeleted);
  }

  void _emitCurrentList(Emitter<TodoState> emit) {
    emit(TodoLoadedState(TodoListModel(todoList: getAllTodos())));
  }

  // Reminder delivery is secondary to saving the task. A permission or
  // platform scheduling error must not make a successful CRUD action fail.
  Future<void> _trySchedule(Todo todo) async {
    try {
      await scheduleTaskNotification(todo);
    } catch (_) {}
  }

  Future<void> _tryCancel(int id) async {
    try {
      await cancelTaskNotification(id);
    } catch (_) {}
  }

  void _onStarted(TodoStartedEvent event, Emitter<TodoState> emit) {
    try {
      emit(TodoLoadingState());
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemAdded(
    TodoItemAddedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await addTodo(event.todo);
      await _trySchedule(event.todo);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemUpdated(
    TodoItemUpdatedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await updateTodo(event.todo);
      await _tryCancel(event.todo.id);
      await _trySchedule(event.todo);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemToggleCompleted(
    TodoItemToggleCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await toggleCompleteTodo(event.todo);
      if (event.todo.isCompleted) {
        // It was completed and is now active again.
        await _trySchedule(event.todo);
      } else {
        await _tryCancel(event.todo.id);
      }
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemDeleted(
    TodoItemDeletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await deleteTodo(event.id);
      await _tryCancel(event.id);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }

  Future<void> _onItemUndoDeleted(
    TodoItemUndoDeletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await undoDeletedTodo(event.todo);
      await _trySchedule(event.todo);
      _emitCurrentList(emit);
    } catch (_) {
      emit(const TodoErrorState());
    }
  }
}
