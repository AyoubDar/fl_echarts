
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'webview_common.dart';

class EChartsWebViewWindows implements EChartsWebView {
  final _controller = WebviewController();

  @override
  Future<void> init(
    VoidCallback onLoaded,
    Function(String) onError,
    Function(String) onMessage,
    VoidCallback onCreated,
    String htmlContent,
  ) async {
    try {
      await _controller.initialize();
      await _controller.setBackgroundColor(Colors.transparent);
      
      _controller.webMessage.listen((message) {
         if (message is String) {
            onMessage(message);
         } else if (message is Map || message is List) {
            try {
              onMessage(jsonEncode(message));
            } catch (e) {
               onMessage(message.toString());
            }
         } else if (message != null) {
            onMessage(message.toString());
         }
      });

      await _controller.loadStringContent(htmlContent);
      onCreated();
      onLoaded();
    } catch (e) {
      onError(e.toString());
    }
  }
  
  @override
  Future<void> loadHtmlString(String html) async {
    await _controller.loadStringContent(html);
  }

  @override
  Future<void> runJavaScript(String script) async {
    await _controller.executeScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Webview(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
  }
}

EChartsWebView createWebView() => EChartsWebViewWindows();
