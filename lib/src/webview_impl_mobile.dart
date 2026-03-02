import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_common.dart';

class EChartsWebViewMobile implements EChartsWebView {
  WebViewController? _controller;

  @override
  Future<void> init(
    VoidCallback onLoaded,
    Function(String) onError,
    Function(String) onMessage,
    VoidCallback onCreated,
    String htmlContent,
  ) async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // onLoaded(); // Logic handled by JS message usually
          },
          onWebResourceError: (WebResourceError error) {
            onError('WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterECharts',
        onMessageReceived: (JavaScriptMessage message) {
          onMessage(message.message);
        },
      );
    
    await _controller!.loadHtmlString(htmlContent);
    onCreated();
  }

  @override
  Future<void> loadHtmlString(String html) async {
    await _controller?.loadHtmlString(html);
  }

  @override
  Future<void> runJavaScript(String script) async {
    await _controller?.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return const SizedBox.shrink();
    return WebViewWidget(controller: _controller!);
  }

  @override
  void dispose() {
    // WebViewController doesn't need explicit disposal usually
  }
}

EChartsWebView createWebView() => EChartsWebViewMobile();
