### Import the package

```dart
import 'package:firestore_size/firestore_size.dart';
```

### Get the size of a document

```dart
// Get the document size
final int docSize = FirestoreSize.sizeOf(docSnapshot);

// Get the size of the data in the document
final int dataSize = FirestoreSize.sizeOf(map);

// Get the document size with extension
final int docSize = docSnapshot.sizeInBytes();

// pretty print the size
print(docSize.prettySize()); // Prints size like 256 Bytes, 1 KB, 2 MB etc.
```