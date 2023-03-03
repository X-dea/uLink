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

import 'dart:convert';
import 'dart:typed_data';

import '../message/typed_message.dart';
import 'codec.dart';

/// A binary codec for [TypedMessage] which encodes the [TypedMessage.message]
/// using JSON. [Null] message will be ignored.
class JSONTypedMessageBinaryCodec extends BinaryCodec<TypedMessage<dynamic>> {
  final int typeLength;

  const JSONTypedMessageBinaryCodec({this.typeLength = 1})
      : assert(typeLength >= 1 && typeLength <= 8);

  @override
  TypedMessage decode(Uint8List data) {
    var type = 0;

    // Extract type.
    for (var i = 0; i < typeLength; i++) {
      type |= data[i] << (8 * (typeLength - i - 1));
    }

    return TypedMessage(
      type,
      data.length == typeLength
          ? null
          : jsonDecode(utf8.decode(data.sublist(typeLength))),
    );
  }

  @override
  Uint8List encode(TypedMessage msg) {
    final messageEncoded =
        msg.message == null ? <int>[] : utf8.encode(jsonEncode(msg.message));
    final encoded = Uint8List(typeLength + messageEncoded.length)
      ..setAll(typeLength, messageEncoded);

    // Fill the type.
    for (var i = 0; i < typeLength; i++) {
      encoded[typeLength - i - 1] = msg.type >> (8 * i);
    }

    return encoded;
  }
}
