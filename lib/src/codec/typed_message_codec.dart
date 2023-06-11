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
  @override
  final Converter<TypedMessage, Uint8List> encoder;

  @override
  final Converter<Uint8List, TypedMessage> decoder;

  JSONTypedMessageBinaryCodec({int typeLength = 1})
      : assert(typeLength >= 1 && typeLength <= 8),
        encoder = _JSONTypedMessageBinaryEncoder(typeLength: typeLength),
        decoder = _JSONTypedMessageBinaryDecoder(typeLength: typeLength);
}

class _JSONTypedMessageBinaryEncoder
    extends Converter<TypedMessage, Uint8List> {
  final int typeLength;

  const _JSONTypedMessageBinaryEncoder({this.typeLength = 1})
      : assert(typeLength >= 1 && typeLength <= 8);

  @override
  Uint8List convert(TypedMessage input) {
    final messageEncoded = input.message == null
        ? <int>[]
        : utf8.encode(jsonEncode(input.message));
    final encoded = Uint8List(typeLength + messageEncoded.length)
      ..setAll(typeLength, messageEncoded);

    // Fill the type.
    for (var i = 0; i < typeLength; i++) {
      encoded[typeLength - i - 1] = input.type >> (8 * i);
    }

    return encoded;
  }
}

class _JSONTypedMessageBinaryDecoder
    extends Converter<Uint8List, TypedMessage> {
  final int typeLength;

  const _JSONTypedMessageBinaryDecoder({this.typeLength = 1})
      : assert(typeLength >= 1 && typeLength <= 8);

  @override
  TypedMessage convert(Uint8List input) {
    var type = 0;

    // Extract type.
    for (var i = 0; i < typeLength; i++) {
      type |= input[i] << (8 * (typeLength - i - 1));
    }

    return TypedMessage(
      type,
      input.length == typeLength
          ? null
          : jsonDecode(utf8.decode(input.sublist(typeLength))),
    );
  }
}
