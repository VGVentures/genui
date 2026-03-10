// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

class _RecordingContentGenerator implements ContentGenerator {
  final _a2uiStream = StreamController<A2uiMessage>.broadcast();
  final _textStream = StreamController<String>.broadcast();
  final _errorStream = StreamController<ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

  Map<String, Object?>? lastMetadata;

  @override
  Stream<A2uiMessage> get a2uiMessageStream => _a2uiStream.stream;

  @override
  Stream<String> get textResponseStream => _textStream.stream;

  @override
  Stream<ContentGeneratorError> get errorStream => _errorStream.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  Future<void> sendRequest(
    ChatMessage message, {
    Iterable<ChatMessage>? history,
    A2UiClientCapabilities? clientCapabilities,
    Map<String, Object?>? metadata,
  }) async {
    lastMetadata = metadata;
  }

  @override
  void dispose() {
    _a2uiStream.close();
    _textStream.close();
    _errorStream.close();
    _isProcessing.dispose();
  }
}

void main() {
  test('sendRequest forwards metadata to ContentGenerator', () async {
    final contentGenerator = _RecordingContentGenerator();
    final conversation = GenUiConversation(
      contentGenerator: contentGenerator,
      a2uiMessageProcessor: A2uiMessageProcessor(catalogs: const []),
    );

    await conversation.sendRequest(
      UserMessage.text('Hello'),
      metadata: {'tenantId': 'tenant-123'},
    );

    expect(contentGenerator.lastMetadata, {'tenantId': 'tenant-123'});

    conversation.dispose();
  });
}
