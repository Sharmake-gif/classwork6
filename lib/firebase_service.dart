import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Task>> getTasks(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Task.fromMap(doc.id, doc.data()))
                  .toList(),
        );
  }

  Future<void> addTask(String uid, Task task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTask(String uid, Task task) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
