import 'package:flutter/widgets.dart';
import 'webview_common.dart';

class EChartsWebViewUnsupported implements EChartsWebView {
  @override
  Future<void> init(
    VoidCallback onLoaded,
    Function(String) onError,
    Function(String) onMessage,
    VoidCallback onCreated,
    String htmlContent,
  ) async {
    onError('Platform not supported');
  }

  @override
  Future<void> loadHtmlString(String html) async {}

  @override
  Future<void> runJavaScript(String script) async {}

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Platform not supported'));
  }

  @override
  void dispose() {}
}

EChartsWebView createWebView() => EChartsWebViewUnsupported();
