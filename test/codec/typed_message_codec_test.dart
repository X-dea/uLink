import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ulink/ulink.dart';

void main() {
  group('TypedMessageBinaryCodec', () {
    test('encodes and decodes message with default settings', () {
      final codec = TypedMessageBinaryCodec();
      final message = TypedMessage(1, {'key': 'value'});

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, equals(message.message));
    });

    test('encodes and decodes message with null message', () {
      final codec = TypedMessageBinaryCodec();
      final message = TypedMessage(1, null);

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, isNull);
    });

    test('encodes and decodes message with custom typeLength', () {
      final codec = TypedMessageBinaryCodec(typeLength: 4);
      final message = TypedMessage(0x01020304, 'test message');

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, equals(message.message));
    });

    test('throws AssertionError when typeLength is invalid', () {
      expect(() => TypedMessageBinaryCodec(typeLength: 0),
          throwsA(isA<AssertionError>()));
      expect(() => TypedMessageBinaryCodec(typeLength: 9),
          throwsA(isA<AssertionError>()));
    });

    test('encodes and decodes message with maximum typeLength', () {
      final codec = TypedMessageBinaryCodec(typeLength: 8);
      final type = 0x0102030405060708;
      final message = TypedMessage(type, 'test message');

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(type));
      expect(decoded.message, equals(message.message));
    });

    test('encodes and decodes message with empty message', () {
      final codec = TypedMessageBinaryCodec();
      final message = TypedMessage(1, '');

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, equals(''));
    });

    test('encodes and decodes message with List message', () {
      final codec = TypedMessageBinaryCodec();
      final message = TypedMessage(1, [1, 2, 3]);

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, equals(message.message));
    });

    test('encodes and decodes message with Map message', () {
      final codec = TypedMessageBinaryCodec();
      final message = TypedMessage(1, {'a': 1, 'b': 2});

      final encoded = codec.encode(message);
      final decoded = codec.decode(encoded);

      expect(decoded.type, equals(message.type));
      expect(decoded.message, equals(message.message));
    });
  });
}
