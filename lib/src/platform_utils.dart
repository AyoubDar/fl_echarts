
import 'package:flutter/foundation.dart';

class PlatformDetector {
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
  static bool get isWeb => kIsWeb;
  static bool get isDesktop => isWindows || isMacOS;

  /// True on platforms that use the webview_flutter WebViewController
  /// (Android, iOS, macOS).
  static bool get usesFlutterWebView => isMobile || isMacOS;

  static String get platformName {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return 'android';
      case TargetPlatform.iOS: return 'ios';
      case TargetPlatform.windows: return 'windows';
      case TargetPlatform.macOS: return 'macos';
      case TargetPlatform.linux: return 'linux';
      case TargetPlatform.fuchsia: return 'fuchsia';
    }
  }

  /// Check if the current platform is supported by this package
  static bool get isSupported => usesFlutterWebView || isWindows || isWeb;
}

