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

import 'dart:io';
import 'dart:typed_data';

import 'channel.dart';

/// A [BinaryChannel] via UDP.
class UdpChannel implements BinaryChannel {
  final InternetAddress address;
  final int port;

  RawDatagramSocket? _socket;
  Stream<Uint8List>? _stream;

  factory UdpChannel(Uri uri) {
    assert(uri.scheme == 'udp');
    return UdpChannel._(InternetAddress(uri.host), uri.port);
  }

  UdpChannel._(this.address, this.port);

  @override
  Future<void> open() async {
    final s = _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    _stream = s
        .where((event) => event == RawSocketEvent.read)
        .map((event) => s.receive()!.data)
        .asBroadcastStream();
  }

  @override
  Future<void> close() async {
    _socket?.close();
    _socket = null;
    _stream = null;
  }

  @override
  Future<void> send(Uint8List data) async {
    _socket?.send(data, address, port);
  }

  @override
  Stream<Uint8List> receive() => _stream!;
}
