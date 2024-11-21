import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ulink/ulink.dart';

void main() {
  group('TerminatorSplitter', () {
    test('splits data with single terminator', () async {
      final terminator = [0x0A]; // Newline character
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 3, 0x0A, 4, 5, 6, 0x0A, 7, 8, 9])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      for (var data in inputData) {
        controller.add(data);
      }
      await controller.close();

      // Wait for all events to be processed
      await Future.delayed(Duration(milliseconds: 100));

      final expectedOutputs = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];
      expect(outputs, equals(expectedOutputs));
    });

    test('splits data with multiple terminators', () async {
      final terminator = [0x0A];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 0x0A, 3, 4, 0x0A, 5, 6, 0x0A])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      for (var data in inputData) {
        controller.add(data);
      }
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      final expectedOutputs = [
        Uint8List.fromList([1, 2]),
        Uint8List.fromList([3, 4]),
        Uint8List.fromList([5, 6]),
      ];
      expect(outputs, equals(expectedOutputs));
    });

    test('handles data without terminators', () async {
      final terminator = [0x0A];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 3, 4, 5, 6])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      for (var data in inputData) {
        controller.add(data);
      }
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      expect(outputs, isEmpty);
    });

    test('handles partial terminator at the end', () async {
      final terminator = [0x0D, 0x0A];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 3, 0x0D])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      controller.add(inputData[0]);
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      expect(outputs, isEmpty);
    });

    test('works with different terminators', () async {
      final terminator = [0xFF, 0xFE];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 3, 0xFF, 0xFE, 4, 5, 6, 0xFF, 0xFE])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      controller.add(inputData[0]);
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      final expectedOutputs = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];
      expect(outputs, equals(expectedOutputs));
    });

    test('handles empty input data', () async {
      final terminator = [0x0A];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [Uint8List.fromList([])];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      controller.add(inputData[0]);
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      expect(outputs, isEmpty);
    });

    test('handles terminators across data chunks', () async {
      final terminator = [0x0D, 0x0A];
      final splitter = TerminatorSplitter(terminator: terminator);
      final inputData = [
        Uint8List.fromList([1, 2, 3, 0x0D]),
        Uint8List.fromList([0x0A, 4, 5, 6, 0x0D]),
        Uint8List.fromList([0x0A, 7, 8, 9])
      ];

      final controller = StreamController<Uint8List>();
      final outputs = <Uint8List>[];

      controller.stream.transform(splitter).listen((data) {
        outputs.add(data);
      });

      for (var data in inputData) {
        controller.add(data);
      }
      await controller.close();

      await Future.delayed(Duration(milliseconds: 100));

      final expectedOutputs = [
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5, 6]),
      ];
      expect(outputs, equals(expectedOutputs));
    });
  });
}
