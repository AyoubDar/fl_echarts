
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'webview_common.dart';
import 'webview_impl_mobile.dart' as mobile;
import 'webview_impl_windows.dart' as windows;

EChartsWebView createWebView() {
  if (kIsWeb) {
    throw UnimplementedError('Web support is not available for this package.');
  } else if (Platform.isWindows) {
    return windows.EChartsWebViewWindows();
  } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return mobile.EChartsWebViewMobile();
  }
  throw UnimplementedError('Platform not supported: ${Platform.operatingSystem}');
}
