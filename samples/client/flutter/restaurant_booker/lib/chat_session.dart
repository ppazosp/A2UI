// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import 'package:genui_a2a/genui_a2a.dart';
import 'package:logging/logging.dart';

import 'message.dart';

/// A class that manages the chat session state and logic.
class ChatSession extends ChangeNotifier {
  ChatSession({required String agentUrl}) {
    _connector = A2uiAgentConnector(url: Uri.parse(agentUrl));
    _surfaceController = SurfaceController(
      catalogs: [BasicCatalogItems.asCatalog()],
    );
    _init();
  }

  late final A2uiAgentConnector _connector;
  late final SurfaceController _surfaceController;

  SurfaceHost get surfaceController => _surfaceController;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  final List<Message> _messages = [];
  List<Message> get messages => List.unmodifiable(_messages);

  final Logger _logger = Logger('ChatSession');

  late final StreamSubscription<A2uiMessage> _a2uiSubscription;
  late final StreamSubscription<String> _textSubscription;
  late final StreamSubscription<ChatMessage> _submitSubscription;
  late final StreamSubscription<Object> _errorSubscription;

  void _init() {
    _a2uiSubscription = _connector.stream.listen((message) {
      switch (message) {
        case CreateSurface(:final surfaceId):
          _surfaceController.handleMessage(message);
          final bool exists = _messages.any((m) => m.surfaceId == surfaceId);
          if (!exists) {
            _messages.add(
              Message(isUser: false, text: null, surfaceId: surfaceId),
            );
            notifyListeners();
          }
        default:
          _surfaceController.handleMessage(message);
      }
    });

    _textSubscription = _connector.textStream.listen(_updateAiMessage);

    _submitSubscription = _surfaceController.onSubmit.listen(_sendChatMessage);

    _errorSubscription = _connector.errorStream.listen((error) {
      _logger.severe('A2A error', error);
      _messages.add(Message(isUser: false, text: 'Error: $error'));
      notifyListeners();
    });
  }

  Message? _currentAiMessage;

  void _updateAiMessage(String chunk) {
    if (_currentAiMessage == null) {
      _currentAiMessage = Message(isUser: false, text: '');
      _messages.add(_currentAiMessage!);
    }
    _currentAiMessage!.text = (_currentAiMessage!.text ?? '') + chunk;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    _currentAiMessage = null;
    _messages.add(Message(isUser: true, text: 'You: $text'));
    notifyListeners();
    await _sendChatMessage(ChatMessage.user(text));
  }

  Future<void> _sendChatMessage(ChatMessage message) async {
    _isProcessing = true;
    notifyListeners();
    try {
      await _connector.connectAndSend(message);
    } catch (error, stackTrace) {
      _logger.severe('Error sending message', error, stackTrace);
      _messages.add(Message(isUser: false, text: 'Error: $error'));
      notifyListeners();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _a2uiSubscription.cancel();
    _textSubscription.cancel();
    _submitSubscription.cancel();
    _errorSubscription.cancel();
    _surfaceController.dispose();
    _connector.dispose();
    super.dispose();
  }
}
