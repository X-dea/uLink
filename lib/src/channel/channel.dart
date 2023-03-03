// Copyright 2023 Jason C.H

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:typed_data';

/// A bidirectional communication channel.
abstract class Channel<T> {
  /// Open the channel.
  Future<void> open();

  /// Close the channel.
  Future<void> close();

  /// Send [data] to the channel.
  Future<void> send(T data);

  /// Receive data from the channel.
  Stream<T> receive();
}

/// A bidirectional communication channel for binary data.
abstract class BinaryChannel extends Channel<Uint8List> {
  /// Send [data] to the channel.
  @override
  Future<void> send(Uint8List data);

  /// Receive data from the channel.
  @override
  Stream<Uint8List> receive();
}
