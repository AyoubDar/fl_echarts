import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformDetector {
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => isWindows || isMacOS;

  /// True on platforms that use the webview_flutter WebViewController
  /// (Android, iOS, macOS).
  static bool get usesFlutterWebView => isMobile || isMacOS;

  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  static bool get isSupported => usesFlutterWebView || isWindows;
}
