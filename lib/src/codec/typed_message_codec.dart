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

/// A binary codec for [TypedMessage] that encodes the [TypedMessage.message]
/// using [messageCodec] (json+utf8 by default). [Null] message will be ignored.
class TypedMessageBinaryCodec<T> extends BinaryCodec<TypedMessage<T>> {
  final Codec<dynamic, List<int>> messageCodec;

  @override
  late final Converter<TypedMessage<T>, Uint8List> encoder;

  @override
  late final Converter<Uint8List, TypedMessage<T>> decoder;

  TypedMessageBinaryCodec({
    int typeLength = 1,
    Codec<dynamic, List<int>>? messageCodec,
  })  : assert(typeLength >= 1 && typeLength <= 8),
        messageCodec = messageCodec ?? json.fuse(utf8) {
    encoder = _TypedMessageBinaryEncoder(
      typeLength: typeLength,
      messageEncoder: this.messageCodec.encoder,
    );
    decoder = _TypedMessageBinaryDecoder(
      typeLength: typeLength,
      messageDecoder: this.messageCodec.decoder,
    );
  }
}

class _TypedMessageBinaryEncoder<T>
    extends Converter<TypedMessage<T>, Uint8List> {
  final int typeLength;
  final Converter<dynamic, List<int>> messageEncoder;

  _TypedMessageBinaryEncoder({
    this.typeLength = 1,
    Converter<dynamic, List<int>>? messageEncoder,
  })  : assert(typeLength >= 1 && typeLength <= 8),
        messageEncoder = messageEncoder ?? json.fuse(utf8).encoder;

  @override
  Uint8List convert(TypedMessage<T> input) {
    final messageEncoded =
        input.message == null ? <int>[] : messageEncoder.convert(input.message);
    final encoded = Uint8List(typeLength + messageEncoded.length)
      ..setAll(typeLength, messageEncoded);

    // Fill the type.
    for (var i = 0; i < typeLength; i++) {
      encoded[typeLength - i - 1] = input.type >> (8 * i);
    }

    return encoded;
  }
}

class _TypedMessageBinaryDecoder<T>
    extends Converter<Uint8List, TypedMessage<T>> {
  final int typeLength;
  final Converter<List<int>, dynamic> messageDecoder;

  _TypedMessageBinaryDecoder({
    this.typeLength = 1,
    Converter<List<int>, dynamic>? messageDecoder,
  })  : assert(typeLength >= 1 && typeLength <= 8),
        messageDecoder = messageDecoder ?? json.fuse(utf8).decoder;

  @override
  TypedMessage<T> convert(Uint8List input) {
    var type = 0;

    // Extract type.
    for (var i = 0; i < typeLength; i++) {
      type |= input[i] << (8 * (typeLength - i - 1));
    }

    return TypedMessage(
      type,
      input.length == typeLength
          ? null
          : messageDecoder.convert(input.sublist(typeLength)),
    );
  }
}
