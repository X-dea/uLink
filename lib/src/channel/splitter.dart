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

/// Split the packet by terminator.
class TerminatorSplitter extends StreamTransformerBase<Uint8List, Uint8List> {
  final int maxBufferSize;
  final List<int> terminator;

  var _partial = <int>[];
  late final StreamController<Uint8List> _controller;
  Stream<Uint8List>? _upstream;
  StreamSubscription? _subscription;

  TerminatorSplitter({
    required this.terminator,
    this.maxBufferSize = 4096,
  }) {
    _controller = StreamController(
      onListen: () => _subscription = _upstream?.listen(_onData),
      onPause: () => _subscription?.pause(),
      onResume: () => _subscription?.resume(),
      onCancel: () => _onCancel,
    );
  }

  /// Use KMP to find the first index of [pattern] in [source].
  int _kmp<T>(List<T> source, List<T> pattern) {
    if (source.isEmpty) return -1;
    final sourceLength = source.length;
    final patternLength = pattern.length;

    final next = List<int>.filled(patternLength, 0);
    for (var i = 1, maxFixLen = 0; i < patternLength; i++) {
      while (maxFixLen > 0 && pattern[i] != pattern[maxFixLen]) {
        maxFixLen = next[maxFixLen - 1];
      }
      if (pattern[i] == pattern[maxFixLen]) maxFixLen++;
      next[i] = maxFixLen;
    }

    for (var i = 0, matchedLen = 0; i < sourceLength; i++) {
      while (matchedLen > 0 && source[i] != pattern[matchedLen]) {
        matchedLen = next[matchedLen - 1];
      }
      if (source[i] == pattern[matchedLen]) matchedLen++;
      if (patternLength == matchedLen) return i - patternLength + 1;
    }

    return -1;
  }

  void _onData(Uint8List data) {
    if (_partial.length > maxBufferSize) {
      _partial = _partial.sublist(_partial.length - maxBufferSize);
    }
    _partial.addAll(data);
    while (_partial.length >= terminator.length) {
      final index = _kmp(_partial, terminator);
      if (index == -1) return;
      final packet = Uint8List.fromList(_partial.sublist(0, index));
      _controller.add(packet);
      _partial = _partial.sublist(index + terminator.length);
    }
  }

  void _onCancel() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) {
    _upstream = stream;
    return _controller.stream;
  }
}
