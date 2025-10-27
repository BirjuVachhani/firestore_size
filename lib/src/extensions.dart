import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'firestore_size.dart';

/// Extension methods for [DocumentSnapshot].
extension DocumentSnapshotExt on DocumentSnapshot {
  /// Calculate the size of this document snapshot.
  int sizeInBytes() => FirestoreSize.sizeOfDoc(this);
}

/// Extension methods for [QuerySnapshot].
extension QuerySnapshotExt on QuerySnapshot {
  /// Calculate the size of this query snapshot.
  int sizeInBytes() => FirestoreSize.sizeOf(this);
}

/// Helper extensions to work with sizes in bytes.
extension SizeExt on int {
  /// Returns size in KB.
  double get inKB => this / 1024;

  /// Returns size in MB.
  double get inMB => this / 1024 / 1024;

  /// Returns size in GB.
  double get inGB => this / 1024 / 1024 / 1024;

  /// Returns size in TB.
  double get inTB => this / 1024 / 1024 / 1024 / 1024;
}

/// Helper extensions to stringify sizes in human readable format.
extension PrettySizeExt on num {
  /// Returns a human readable string representation of the bytes size.
  String prettySize() {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    const int tb = gb * 1024;

    final (double value, String unit) = switch (this) {
      < kb => (toDouble(), 'bytes'),
      < mb => (this / kb, 'KB'),
      < gb => (this / mb, 'MB'),
      < tb => (this / gb, 'GB'),
      _ => (this / tb, 'TB'),
    };

    return '${_numberFormat.format(value)} $unit';
  }
}

final NumberFormat _numberFormat = NumberFormat('0.##')
  ..minimumFractionDigits = 0;
