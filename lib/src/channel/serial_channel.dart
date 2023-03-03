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

import 'package:usb_serial/usb_serial.dart';

import 'channel.dart';

/// A [BinaryChannel] via serial port.
class SerialChannel implements BinaryChannel {
  final int deviceId;
  final int baudRate;
  final StreamTransformer<Uint8List, Uint8List>? _splitter;

  UsbPort? _port;
  Stream<Uint8List>? _stream;

  factory SerialChannel(
    Uri uri, {
    StreamTransformer<Uint8List, Uint8List>? splitter,
  }) {
    assert(uri.scheme == 'serial');
    return SerialChannel._(
      int.parse(uri.host),
      int.parse(uri.queryParameters['baud_rate'] ?? '460800'),
      splitter,
    );
  }

  SerialChannel._(this.deviceId, this.baudRate, this._splitter);

  @override
  Future<void> open() async {
    final p = _port = await UsbSerial.createFromDeviceId(deviceId);
    if (p == null) return;

    await p.open();
    await p.setDTR(true);
    await p.setRTS(true);
    await p.setPortParameters(
      baudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    final splitter = _splitter;
    if (splitter == null) {
      _stream = p.inputStream?.asBroadcastStream();
    } else {
      _stream = p.inputStream?.transform(splitter).asBroadcastStream();
    }
  }

  @override
  Future<void> close() async {
    await _port?.close();
    _port = null;
    _stream = null;
  }

  @override
  Future<void> send(Uint8List data) async {
    _port?.write(data);
  }

  @override
  Stream<Uint8List> receive() => _stream!;
}
