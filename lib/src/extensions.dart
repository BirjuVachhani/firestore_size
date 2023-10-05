import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'firestore_size.dart';

/// Extension methods for [DocumentSnapshot].
extension DocumentSnapshotExt on DocumentSnapshot {
  /// Calculate the size of this document snapshot.
  int sizeInBytes() => FirestoreSize.sizeOfDoc(this);
}

/// Extension methods for [DocumentSnapshot].
extension QuerySnapshotExt on QuerySnapshot {
  /// Calculate the size of this document snapshot.
  int sizeInBytes() => FirestoreSize.sizeOf(this);
}

/// Helper extensions to work with sizes in bytes.
extension SizeExt on int {
  /// Returns size in KB.
  double get inKB => this / 1024;

  /// Returns size in MB.
  double get inMB => this / 1024 / 1024;
}

/// Helper extensions to stringify sizes in human readable format.
extension PrettySizeExt on num {
  /// Returns a human readable string representation of the bytes size.
  String prettySize() {
    final String unit = switch (this) {
      < 1024 => 'bytes',
      < 1024 * 1024 => 'KB',
      _ => 'MB',
    };

    final valueInUnit = switch (this) {
      < 1024 => this,
      < 1024 * 1024 => this / 1024,
      _ => this / 1024 / 1024,
    };

    return '${_numberFormat.format(valueInUnit)} $unit';
  }
}

final NumberFormat _numberFormat = NumberFormat('0.##')
  ..minimumFractionDigits = 0;
