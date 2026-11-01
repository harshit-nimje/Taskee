import '../repositories/todo_repository.dart';

class DeleteTodo {
  final TodoRepository repository;
  DeleteTodo(this.repository);

  Future<void> call(int id) => repository.deleteTodo(id);
}
