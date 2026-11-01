import '../entities/todo.dart';

abstract class TodoRepository {
  List<Todo> getTodoList();
  Future<void> addTodo(Todo todo);
  Future<void> toggleCompleteTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(int id);
}
