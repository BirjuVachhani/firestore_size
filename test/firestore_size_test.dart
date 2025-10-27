import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firestore_size/firestore_size.dart';
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

    // Firestore-specific types
    // Timestamp (8 bytes)
    expect(FirestoreSize.sizeOf(Timestamp.now()), 8);
    expect(FirestoreSize.sizeOf(Timestamp(1234567890, 0)), 8);
    // GeoPoint (16 bytes)
    expect(FirestoreSize.sizeOf(const GeoPoint(37.7749, -122.4194)), 16);
    expect(FirestoreSize.sizeOf(const GeoPoint(0, 0)), 16);
    // Blob (byte length)
    expect(FirestoreSize.sizeOf(Blob(Uint8List(0))), 0);
    expect(FirestoreSize.sizeOf(Blob(Uint8List(10))), 10);
    expect(FirestoreSize.sizeOf(Blob(Uint8List.fromList([1, 2, 3, 4, 5]))), 5);

    // Strings
    expect(FirestoreSize.sizeOf(''), 1);
    expect(FirestoreSize.sizeOf('a'), 2);
    expect(FirestoreSize.sizeOf('tasks'), 6);

    // UTF-8 / Unicode strings
    // Emoji (4 bytes in UTF-8 + 1)
    expect(FirestoreSize.sizeOf('😀'), 5);
    expect(FirestoreSize.sizeOf('👍'), 5);
    expect(FirestoreSize.sizeOf('🔥'), 5);
    // Mixed ASCII and emoji
    expect(FirestoreSize.sizeOf('Hello 😀'), 11); // 6 + 4 + 1
    // Chinese characters (3 bytes each in UTF-8)
    expect(FirestoreSize.sizeOf('你好'), 7); // 3 + 3 + 1
    // Japanese characters (3 bytes each in UTF-8)
    expect(FirestoreSize.sizeOf('こんにちは'), 16); // 15 + 1
    // Arabic characters
    expect(FirestoreSize.sizeOf('مرحبا'), 11); // 10 + 1
    // Mathematical symbols outside BMP (4 bytes in UTF-8)
    expect(FirestoreSize.sizeOf('𝕏'), 5); // 4 + 1

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

  test('Non-existent document test', () async {
    final instance = FakeFirebaseFirestore();
    final ref = instance.collection('users').doc('non_existent_doc');

    final snapshot = await ref.get();

    // Non-existent documents should return 0 size
    expect(snapshot.exists, false);
    expect(FirestoreSize.sizeOf(snapshot), 0);
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
    // KB tests
    expect(1024.inKB, 1);
    expect(512.inKB, 0.5);
    expect(256.inKB, 0.25);

    // MB tests
    expect(1048576.inMB, 1);
    expect((1024 * 1024 * 2).inMB, 2);

    // GB tests
    expect((1024 * 1024 * 1024).inGB, 1);
    expect((1024 * 1024 * 1024 * 5).inGB, 5);
    expect((512 * 1024 * 1024).inGB, 0.5);

    // TB tests
    expect((1024 * 1024 * 1024 * 1024).inTB, 1);
    expect((1024 * 1024 * 1024 * 1024 * 2).inTB, 2);
    expect((512 * 1024 * 1024 * 1024).inTB, 0.5);

    // prettySize tests - bytes
    expect(512.prettySize(), '512 bytes');
    expect(256.prettySize(), '256 bytes');

    // prettySize tests - KB
    expect(1024.prettySize(), '1 KB');
    expect(1536.prettySize(), '1.5 KB');
    expect(4096.prettySize(), '4 KB');

    // prettySize tests - MB
    expect((1024 * 1024).prettySize(), '1 MB');
    expect((1024 * 1024 * 2.5).prettySize(), '2.5 MB');
    expect((1024 * 1024 * 4.56).prettySize(), '4.56 MB');
    expect((1024 * 1024 * 4.567).prettySize(), '4.57 MB');

    // prettySize tests - GB
    expect((1024 * 1024 * 1024).prettySize(), '1 GB');
    expect((1024 * 1024 * 1024 * 2.5).prettySize(), '2.5 GB');
    expect((1024 * 1024 * 1024 * 5.75).prettySize(), '5.75 GB');

    // prettySize tests - TB
    expect((1024 * 1024 * 1024 * 1024).prettySize(), '1 TB');
    expect((1024 * 1024 * 1024 * 1024 * 2.5).prettySize(), '2.5 TB');
    expect((1024 * 1024 * 1024 * 1024 * 3.14).prettySize(), '3.14 TB');
  });
}
