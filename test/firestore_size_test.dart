import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_size/firestore_size.dart';
import 'package:firestore_size/src/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('data type size tests', () {
    expect(FirestoreSize.sizeOf(null), 1);

    // bool
    expect(FirestoreSize.sizeOf(true), 1);
    expect(FirestoreSize.sizeOf(false), 1);

    // numbers
    expect(FirestoreSize.sizeOf(1), 8);
    expect(FirestoreSize.sizeOf(1.0), 8);

    // Strings
    expect(FirestoreSize.sizeOf(''), 1);
    expect(FirestoreSize.sizeOf('a'), 2);
    expect(FirestoreSize.sizeOf('tasks'), 6);

    // Lists
    expect(FirestoreSize.sizeOf([]), 0);
    expect(FirestoreSize.sizeOf([1]), 8);
    expect(FirestoreSize.sizeOf([1, 2.0]), 16);
    expect(FirestoreSize.sizeOf([true]), 1);
    expect(FirestoreSize.sizeOf([false]), 1);
    expect(FirestoreSize.sizeOf([null]), 1);
    expect(FirestoreSize.sizeOf(['tasks']), 6);

    // Maps
    expect(FirestoreSize.sizeOf({}), 0);
    expect(FirestoreSize.sizeOf({'type': 'Personal'}), 14);
    expect(FirestoreSize.sizeOf({'priority': 1}), 17);
    expect(FirestoreSize.sizeOf({'done': false}), 6);

    // unsupported objects
    expect(
      () => FirestoreSize.sizeOf(RegExp('')),
      throwsArgumentError,
    );
    expect(
      () => FirestoreSize.sizeOf(('name', 'john')),
      throwsArgumentError,
    );
  });

  test('Document name/path size test', () {
    expect(
      FirestoreSize.documentNameSize('users/jeff/tasks/my_task_id'),
      44,
    );
  });

  test('Document size test', () {
    final Map<String, dynamic> data = {
      'type': 'Personal',
      'done': false,
      'priority': 1,
      'description': 'Learn Cloud Firestore'
    };
    expect(
        FirestoreSize.sizeOfDoc(
          data,
          path: 'users/jeff/tasks/my_task_id',
        ),
        147);
  });

  test('Document snapshot test', () async {
    final Map<String, dynamic> data = {
      'type': 'Personal',
      'done': false,
      'priority': 1,
      'description': 'Learn Cloud Firestore'
    };

    final instance = FakeFirebaseFirestore();
    final ref = instance
        .collection('users')
        .doc('jeff')
        .collection('tasks')
        .doc('my_task_id');
    await ref.set(data);

    final snapshot = await ref.get();

    expect(FirestoreSize.sizeOfDoc(snapshot), 147);
    expect(FirestoreSize.sizeOf(snapshot), 147);
    expect(snapshot.sizeInBytes(), 147);

    expect(FirestoreSize.sizeOf(ref), 44);
  });

  test('Query snapshot test', () async {
    final Map<String, dynamic> data = {
      'type': 'Personal',
      'done': false,
      'priority': 1,
      'description': 'Learn Cloud Firestore'
    };

    final instance = FakeFirebaseFirestore();
    final docRef = instance
        .collection('users')
        .doc('jeff')
        .collection('tasks')
        .doc('my_task_id');
    await docRef.set(data);

    final query = instance
        .collection('users')
        .doc('jeff')
        .collection('tasks')
        .where('priority', isEqualTo: 1);

    final snapshot = await query.get();

    expect(FirestoreSize.sizeOfDoc(snapshot), 147);
    expect(FirestoreSize.sizeOf(snapshot), 147);
    expect(snapshot.sizeInBytes(), 147);
  });

  test('size extension tests', () {
    expect(1024.inKB, 1);
    expect(512.inKB, 0.5);
    expect(256.inKB, 0.25);
    expect(1048576.inMB, 1);

    expect(512.prettySize(), '512 bytes');
    expect(256.prettySize(), '256 bytes');
    expect(1024.prettySize(), '1 KB');
    expect(1536.prettySize(), '1.5 KB');
    expect(4096.prettySize(), '4 KB');
    expect((1024 * 1024).prettySize(), '1 MB');
    expect((1024 * 1024 * 2.5).prettySize(), '2.5 MB');
    expect((1024 * 1024 * 4.56).prettySize(), '4.56 MB');
    expect((1024 * 1024 * 4.567).prettySize(), '4.57 MB');
  });
}
