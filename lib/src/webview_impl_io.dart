import 'dart:io';
import 'webview_common.dart';
import 'webview_impl_mobile.dart';
import 'webview_impl_windows.dart' as win;

Future<EChartsWebView> createWebView() async {
  if (Platform.isWindows) {
    return win.EChartsWebViewWindows();
  }
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return EChartsWebViewMobile();
  }
  throw UnimplementedError(
      'Platform not supported: ${Platform.operatingSystem}');
}
