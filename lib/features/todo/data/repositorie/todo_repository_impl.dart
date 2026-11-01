import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasource/todo_local_datasource.dart';
import '../mappers/todo_mapper.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;
  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<void> addTodo(Todo todo) =>
      localDataSource.save(todo.toHiveModel());

  @override
  Future<void> toggleCompleteTodo(Todo todo) => localDataSource.update(
        todo.id,
        Todo(
          id: todo.id,
          title: todo.title,
          isCompleted: !todo.isCompleted,
          dueAt: todo.dueAt,
        ).toHiveModel(),
      );

  @override
  Future<void> deleteTodo(int id) => localDataSource.delete(id);

  @override
  List<Todo> getTodoList() =>
      localDataSource.getAll().map((e) => e.toDomain()).toList();

  @override
  Future<void> updateTodo(Todo todo) =>
      localDataSource.update(todo.id, todo.toHiveModel());
}
