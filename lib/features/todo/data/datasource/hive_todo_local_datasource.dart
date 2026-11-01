import 'package:hive_flutter/hive_flutter.dart';

import '../model/todo_hive_model.dart';
import 'todo_local_datasource.dart';

const String _todoBoxName = 'todoBox';
const String _latestIdBoxName = 'latestIdBox';
const String _latestIdName = '_latestId';

class HiveTodoLocalDataSource implements TodoLocalDataSource {
  late final Box<TodoHiveModel> _todoBox;
  late final Box<int> _lastIdBox;

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoHiveModelAdapter());
    }
    _todoBox = await Hive.openBox<TodoHiveModel>(_todoBoxName);
    _lastIdBox = await Hive.openBox<int>(_latestIdBoxName);
  }

  @override
  List<TodoHiveModel> getAll() => _todoBox.values.toList();

  @override
  Future<void> save(TodoHiveModel todo) async {
    // Preserve an existing ID when restoring a deleted task. New tasks use
    // the next ID, while the counter is advanced to avoid future collisions.
    final latestId = _lastIdBox.get(_latestIdName, defaultValue: 0) ?? 0;
    final id = todo.id > 0 ? todo.id : latestId + 1;
    final entity = TodoHiveModel(
      id: id,
      title: todo.title,
      isCompleted: todo.isCompleted,
      dueAt: todo.dueAt,
    );
    await _todoBox.put(id, entity);
    if (id > latestId) {
      await _lastIdBox.put(_latestIdName, id);
    }
  }

  @override
  Future<void> update(int id, TodoHiveModel todo) =>
      _todoBox.put(id, todo);

  @override
  Future<void> delete(int id) => _todoBox.delete(id);
}
