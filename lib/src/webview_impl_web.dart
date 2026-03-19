// This file is only imported on web platforms (dart.library.js_interop / dart.library.html).
// It uses a raw HtmlElementView + iframe so that:
//   1. window.parent.postMessage() from the iframe reaches the Flutter window directly.
//   2. Flutter can send JS commands back via contentWindow.postMessage().
// This avoids webview_flutter_web which does not implement addJavaScriptChannel.

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/widgets.dart';
import 'webview_common.dart';

int _viewCounter = 0;

class EChartsWebViewWeb implements EChartsWebView {
  late final String _viewId;
  html.IFrameElement? _iframe;
  void Function(html.Event)? _messageListener;

  @override
  Future<void> init(
    VoidCallback onLoaded,
    Function(String) onError,
    Function(String) onMessage,
    VoidCallback onCreated,
    String htmlContent,
  ) async {
    _viewId = 'fl_echarts_${_viewCounter++}';

    // Listen for window.parent.postMessage() calls from the iframe.
    _messageListener = (html.Event event) {
      if (event is html.MessageEvent) {
        final data = event.data;
        if (data is String) {
          onMessage(data);
        }
      }
    };
    html.window.addEventListener('message', _messageListener);

    // Register the iframe as a Flutter platform view.
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
      _iframe = html.IFrameElement()
        ..src = _createBlobUrl(htmlContent)
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return _iframe!;
    });

    onCreated();
    // The {type:'ready'} message arrives via postMessage once the chart is initialised.
  }

  /// Creates an object URL for [content] typed as text/html and returns it.
  /// Using a Blob URL (instead of srcdoc) keeps the DOM attribute small and
  /// avoids browser limits on srcdoc content size (~1 MB for echarts).
  String _createBlobUrl(String content) {
    final blob = html.Blob([content], 'text/html');
    return html.Url.createObjectUrl(blob);
  }

  @override
  Future<void> loadHtmlString(String htmlString) async {
    if (_iframe != null) {
      // Revoke previous blob URL to avoid memory leaks.
      final oldSrc = _iframe!.src;
      if (oldSrc != null && oldSrc.startsWith('blob:')) {
        html.Url.revokeObjectUrl(oldSrc);
      }
      _iframe!.src = _createBlobUrl(htmlString);
    }
  }

  @override
  Future<void> runJavaScript(String script) async {
    // Post a command to the iframe; the HTML template's message listener executes it.
    _iframe?.contentWindow?.postMessage(
      {'_flEchartsCmd': true, 'script': script},
      '*',
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }

  @override
  void dispose() {
    if (_messageListener != null) {
      html.window.removeEventListener('message', _messageListener);
      _messageListener = null;
    }
  }
}

Future<EChartsWebView> createWebView() async => EChartsWebViewWeb();
