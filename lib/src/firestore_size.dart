import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Size calculator for Firestore data.
///
/// Ref: https://cloud.google.com/firestore/docs/storage-size
final class FirestoreSize {
  FirestoreSize._();

  /// Calculate the size of a Firestore field value.
  ///
  /// The following table shows the size of field values by type:
  /// -------------------------------------------------------------------------
  /// Type	                    Size
  /// -------------------------------------------------------------------------
  /// Array	                    The sum of the sizes of its values.
  /// Boolean	                  1 byte
  /// Bytes	                    Byte length
  /// Date and time	            8 bytes
  /// Floating-point number	    8 bytes
  /// Geographical point	      16 bytes
  /// Integer	                  8 bytes
  /// Map	                      The size of the map, calculated the same way
  ///                           as document size.
  /// Null	                    1 byte
  /// Reference	                The document name size.
  /// Text string	              Number of UTF-8 encoded bytes + 1
  /// -------------------------------------------------------------------------
  ///
  /// e.g. a boolean field named done would use 6 bytes:
  ///   - 5 bytes for the done field name
  ///   - 1 byte for the boolean value
  ///
  /// Ref: https://cloud.google.com/firestore/docs/storage-size#field-size
  ///
  /// Returned integer represents the size in bytes.
  static int sizeOf(Object? value) => switch (value) {
        null => 1,
        String value => _stringSize(value),
        bool() => 1,
        num() => 8,
        Timestamp() => 8,
        GeoPoint() => 16,
        Blob(:Uint8List bytes) => bytes.length,
        DocumentSnapshot(exists: false) => 0,
        DocumentSnapshot doc when doc.exists =>
          sizeOfDoc(doc.data(), path: doc.reference.path),
        QuerySnapshot snapshot =>
          snapshot.docs.fold(0, (sum, doc) => sum + sizeOf(doc)),
        DocumentReference(:String path) => documentNameSize(path),
        List items => items.fold(0, (sum, item) => sum + sizeOf(item)),
        Map map => _sizeOfMap(map),
        _ => throw ArgumentError('Unsupported type: ${value.runtimeType}'),
      };

  /// Calculate the size of a document stored in firestore.
  ///
  /// The size of a document is the sum of:
  ///   - The document name size: [documentNameSize]
  ///   - The sum of the string size of each field name: [_stringSize]
  ///   - The sum of the size of each field value: [sizeOf]
  ///   - 32 additional bytes
  ///
  /// e.g. for a document in subcollection users/jeff/tasks with a string
  ///      document ID of my_task_id:
  ///       - "type": "Personal"
  ///       - "done": false
  ///       - "priority": 1
  ///       - "description": "Learn Cloud Firestore"
  ///
  /// Ref: https://cloud.google.com/firestore/docs/storage-size#document-size
  ///
  /// Returned integer represents the size in bytes.
  static int sizeOfDoc(
    Object? value, {
    String path = '',
  }) {
    if (value case DocumentSnapshot snapshot) {
      value = snapshot.data();
      path = snapshot.reference.path;
    }
    if (value case QuerySnapshot snapshot) {
      return sizeOf(snapshot);
    }
    return 32 + sizeOf(value) + documentNameSize(path);
  }

  /// Calculate the size of a document name/path stored as document reference.
  /// Document ID can be an integer or string. Since Firestore client libraries
  /// always use String document IDs, we can assume that the document ID is a
  /// string.
  ///
  /// The size of a document name is the sum of:
  ///   - The size of each collection ID and document ID in the path to the
  ///     document.
  ///   - 16 additional bytes.
  ///
  /// e.g.
  ///   For a document in the sub-collection users/jeff/tasks with a string
  ///   document ID of my_task_id,
  ///   the document name size is 6 + 5 + 6 + 11 + 16 = 44 bytes:
  ///
  ///   - 6 bytes for the users collection ID
  ///   - 5 bytes for the jeff document ID
  ///   - 6 bytes for the tasks collection ID
  ///   - 11 bytes for the my_task_id document ID
  ///   - 16 additional bytes
  ///
  /// Note: Any documents in sub-collections under the document, for example
  ///       "users/jeff/tasks/my_task_id/comments/D8PvloqiczrzXik3SWjZ",
  ///       aren't counted towards the document name size or the 1 MiB limit
  ///       for the users/jeff/tasks/my_task_id document.
  ///
  /// Ref: https://cloud.google.com/firestore/docs/storage-size#document-name-size
  ///
  /// Returned integer represents the size in bytes.
  static int documentNameSize(String path) {
    if (path.isEmpty) return 0;
    return path.split('/').fold(0, (sum, item) => sum + _stringSize(item)) + 16;
  }

  static int _sizeOfMap(Map? map) {
    if (map == null) return 1;
    int bytes = 0;
    for (final MapEntry(:key, :value) in map.entries) {
      bytes += sizeOf(key) + sizeOf(value);
    }

    return bytes;
  }

  /// get bytes in string
  /// https://stackoverflow.com/a/23329386/591487
  static int _byteLength(String value) {
    // returns the byte length of an utf8 string
    int length = value.length;
    for (var index = value.length - 1; index >= 0; index--) {
      final code = value.codeUnitAt(index);
      length += switch (code) {
        > 0x7f && <= 0x7ff => 1,
        > 0x7ff && <= 0xffff => 2,
        _ => 0,
      };
    }
    return length;
  }

  /// Calculate the size of a string stored in firestore.
  /// String sizes are calculated as the number of UTF-8 encoded bytes + 1.
  ///
  /// The following are stored as strings:
  ///   - Collection IDs
  ///   - String document IDs
  ///   - Document names
  ///   - Field names
  ///   - String field values
  ///
  /// e.g.
  ///   "tasks"       uses    5 bytes + 1 byte  = 6 bytes in total.
  ///   "description" uses    11 bytes + 1 byte = 12 bytes in total.
  ///
  /// Ref: https://cloud.google.com/firestore/docs/storage-size#string-size
  ///
  /// Returned integer represents the size in bytes.
  static int _stringSize(String value) => _byteLength(value) + 1;
}
