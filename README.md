# Firestore Size

[![Build](https://github.com/BirjuVachhani/firestore_size/workflows/Build/badge.svg?branch=main)](https://github.com/BirjuVachhani/firestore_size/actions) [![Tests](https://github.com/BirjuVachhani/firestore_size/workflows/Tests/badge.svg?branch=main)](https://github.com/BirjuVachhani/firestore_size/actions) [![codecov](https://codecov.io/gh/birjuvachhani/firestore_size/branch/main/graph/badge.svg?token=ZTYF9UQJID)](https://codecov.io/gh/birjuvachhani/firestore_size) [![Pub Version](https://img.shields.io/pub/v/firestore_size?label=Pub)](https://pub.dev/packages/firestore_size)

A tiny package to calculate the approximate size (in bytes) of a Firestore document. An improved Dart implementation of 
[firestore-size](https://www.npmjs.com/package/firestore-size) NPM package.

> This package strictly follows [Storage Size reference guide](https://cloud.google.com/firestore/docs/storage-size) by 
> [Google Cloud](https://cloud.google.com) to calculate the size of a document.


## Installation

Add this package to your dependencies in your `pubspec.yaml` file:

```yaml
  dependencies:
    firestore_size: <latest_version>
```

## Usage

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

## Liked this package?

Show some love and support by starring the repository. ⭐

Want to support my work?

<a href="https://github.com/sponsors/BirjuVachhani" target="_blank"><img src="https://raw.githubusercontent.com/BirjuVachhani/spider/main/.github/sponsor.png?raw=true" alt="Sponsor Author" style="!important;width: 600px !important;" ></a>

Or You can

<a href="https://www.buymeacoffee.com/birjuvachhani" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-blue.png" alt="Buy Me A Coffee" style="height: 51px !important;width: 217px !important;" ></a>

## License

```
BSD 3-Clause License

Copyright (c) 2023, Birju Vachhani

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```