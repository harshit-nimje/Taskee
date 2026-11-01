import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodo {
  final TodoRepository repository;
  const UpdateTodo(this.repository);

  Future<void> call(Todo todo) => repository.updateTodo(todo);
}
