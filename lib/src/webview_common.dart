import 'package:flutter/widgets.dart';

abstract class EChartsWebView {
  Future<void> init(
    VoidCallback onLoaded,
    Function(String) onError,
    Function(String) onMessage,
    VoidCallback onCreated,
    String htmlContent,
  );
  Future<void> loadHtmlString(String html);
  Future<void> runJavaScript(String script);
  Widget build(BuildContext context);
  void dispose();
}
